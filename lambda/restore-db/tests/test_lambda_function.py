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
os.environ.setdefault("ALB_NAME", "app-test")

sys.path.insert(0, str(WORKSPACE_ROOT))

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


class ApplicationEndpointTest(unittest.TestCase):
    def test_returns_none_when_elb_lookup_is_not_authorized(self):
        class FakeElbv2Client:
            def describe_load_balancers(self, **kwargs):
                raise ClientError({"Error": {"Code": "AccessDeniedException", "Message": "not authorized"}})

        module.elbv2 = FakeElbv2Client()
        self.assertIsNone(module.get_application_endpoint())

    def test_returns_dns_name_when_elb_lookup_succeeds(self):
        class FakeElbv2Client:
            def describe_load_balancers(self, **kwargs):
                return {"LoadBalancers": [{"DNSName": "internal-lb-123.elb.amazonaws.com"}]}

        module.elbv2 = FakeElbv2Client()
        self.assertEqual(module.get_application_endpoint(), "internal-lb-123.elb.amazonaws.com")


if __name__ == "__main__":
    unittest.main()
