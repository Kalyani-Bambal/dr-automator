import importlib.util
import os
import sys
import types
import unittest
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = WORKSPACE_ROOT / "lambda_function.py"

os.environ.setdefault("DR_REGION", "ap-southeast-1")
os.environ.setdefault("PRIMARY_REGION", "ap-south-1")
os.environ.setdefault("SOURCE_DB_IDENTIFIER", "source-db")
os.environ.setdefault("TARGET_DB_IDENTIFIER", "target-db")
os.environ.setdefault("DB_INSTANCE_CLASS", "db.t3.micro")
os.environ.setdefault("DB_SUBNET_GROUP", "default")
os.environ.setdefault("SECURITY_GROUP_ID", "sg-12345678")

boto3_stub = types.ModuleType("boto3")
boto3_stub.client = lambda *args, **kwargs: None
sys.modules.setdefault("boto3", boto3_stub)

botocore_exceptions_stub = types.ModuleType("botocore.exceptions")
class ClientError(Exception):
    def __init__(self, response):
        self.response = response
        super().__init__(str(response))

botocore_exceptions_stub.ClientError = ClientError
sys.modules.setdefault("botocore", types.ModuleType("botocore"))
sys.modules.setdefault("botocore.exceptions", botocore_exceptions_stub)

spec = importlib.util.spec_from_file_location("restore_lambda", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class ResolveSourceSnapshotIdentifierTest(unittest.TestCase):
    def test_prefers_db_snapshot_arn_for_cross_region_copy(self):
        snapshot = {
            "DBSnapshotIdentifier": "snapshot-id",
            "DBSnapshotArn": "arn:aws:rds:ap-south-1:123456789012:snapshot:snapshot-id",
        }

        self.assertEqual(
            module.resolve_source_snapshot_identifier(snapshot, "ap-south-1"),
            snapshot["DBSnapshotArn"],
        )

    def test_falls_back_to_identifier_when_arn_missing(self):
        snapshot = {"DBSnapshotIdentifier": "snapshot-id"}

        self.assertEqual(
            module.resolve_source_snapshot_identifier(snapshot, "ap-south-1"),
            "snapshot-id",
        )


class RestoreSnapshotTest(unittest.TestCase):
    def test_passes_configured_kms_key_to_restore_call(self):
        class FakeRdsClient:
            def __init__(self):
                self.calls = []

            def restore_db_instance_from_db_snapshot(self, **kwargs):
                self.calls.append(kwargs)
                return {"DBInstance": {"DBInstanceIdentifier": "target-db"}}

        fake_rds = FakeRdsClient()
        module.rds = fake_rds
        module.KMS_KEY_ID = "arn:aws:kms:ap-southeast-1:123456789012:key/test-key"
        module.get_target_db_status = lambda: {"exists": False, "status": None, "endpoint": None, "db": "target-db"}

        module.restore_snapshot("snapshot-id")

        self.assertEqual(fake_rds.calls[0]["KmsKeyId"], module.KMS_KEY_ID)


class CreateFreshSnapshotTest(unittest.TestCase):
    def test_uses_copy_tags_for_snapshot_copy(self):
        class FakeWaiter:
            def wait(self, **kwargs):
                return None

        class FakeSourceClient:
            def __init__(self):
                self.waiter = FakeWaiter()

            def describe_db_instances(self, **kwargs):
                return {"DBInstances": [{"DBInstanceStatus": "available"}]}

            def create_db_snapshot(self, **kwargs):
                return {}

            def get_waiter(self, waiter_name):
                return self.waiter

            def describe_db_snapshots(self, **kwargs):
                return {"DBSnapshots": [{"DBSnapshotIdentifier": "source-snapshot", "DBSnapshotArn": "arn:aws:rds:ap-south-1:123456789012:snapshot:source-snapshot"}]}

        class FakeRdsClient:
            def __init__(self):
                self.calls = []

            def copy_db_snapshot(self, **kwargs):
                self.calls.append(kwargs)
                return {}

            def get_waiter(self, waiter_name):
                return FakeWaiter()

        fake_source_client = FakeSourceClient()
        fake_rds_client = FakeRdsClient()

        module.boto3.client = lambda *args, **kwargs: fake_source_client
        module.rds = fake_rds_client
        module.KMS_KEY_ID = "arn:aws:kms:ap-southeast-1:123456789012:key/test-key"
        module.PRIMARY_REGION = "ap-south-1"
        module.SOURCE_DB_IDENTIFIER = "source-db"
        module.DR_REGION = "ap-southeast-1"

        module.create_fresh_snapshot()

        self.assertTrue(fake_rds_client.calls[0]["CopyTags"])


if __name__ == "__main__":
    unittest.main()
