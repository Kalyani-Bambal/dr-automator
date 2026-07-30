import os
import json
import logging
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

from config import Config

PRIMARY_REGION = os.getenv("PRIMARY_REGION", "ap-south-1")
DR_REGION = Config.DR_REGION
SOURCE_DB_IDENTIFIER = Config.SOURCE_DB_IDENTIFIER
TARGET_DB_IDENTIFIER = Config.TARGET_DB_IDENTIFIER
DB_INSTANCE_CLASS = Config.DB_INSTANCE_CLASS
DB_SUBNET_GROUP = Config.DB_SUBNET_GROUP
SECURITY_GROUP_ID = Config.SECURITY_GROUP_ID
DB_PARAMETER_GROUP = Config.DB_PARAMETER_GROUP
PUBLIC_ACCESS = Config.PUBLIC_ACCESS
MULTI_AZ = Config.MULTI_AZ
ALB_NAME = os.getenv("ALB_NAME")

source_rds = boto3.client("rds", region_name=PRIMARY_REGION)
dr_rds = boto3.client("rds", region_name=DR_REGION)
elbv2 = boto3.client("elbv2", region_name=PRIMARY_REGION)


def response(status_code, message, data=None):
    body = {"message": message, "timestamp": datetime.utcnow().isoformat()}
    if data:
        body["data"] = data
    return {"statusCode": status_code, "body": json.dumps(body)}


def get_latest_snapshot():
    logger.info("Searching for latest DR snapshot...")
    response = dr_rds.describe_db_snapshots()
    snapshots = [
        s for s in response["DBSnapshots"]
        if s["Status"] == "available" and s["DBSnapshotIdentifier"].startswith("dr-automator")
    ]
    if not snapshots:
        raise Exception("No DR snapshots found.")
    snapshots.sort(key=lambda x: x["SnapshotCreateTime"], reverse=True)
    latest = snapshots[0]
    logger.info(f"Using Snapshot: {latest['DBSnapshotIdentifier']}")
    return latest


def database_exists(db_identifier):
    logger.info(f"Checking database: {db_identifier}")
    try:
        dr_rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
        logger.info("Database already exists.")
        return True
    except ClientError as error:
        error_code = error.response["Error"]["Code"]
        if error_code in ("DBInstanceNotFound", "DBInstanceNotFoundFault"):
            logger.info("Database does not exist.")
            return False
        raise


def get_database_status(db_identifier):
    try:
        response = dr_rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
        return response["DBInstances"][0]["DBInstanceStatus"]
    except ClientError:
        return "UNKNOWN"


def get_database_endpoint(db_identifier):
    try:
        response = dr_rds.describe_db_instances(DBInstanceIdentifier=db_identifier)
        endpoint = response["DBInstances"][0].get("Endpoint", {})
        return endpoint.get("Address")
    except ClientError:
        return None


def restore_database(snapshot):
    snapshot_identifier = snapshot["DBSnapshotIdentifier"]
    logger.info(f"Starting restore using snapshot: {snapshot_identifier}")

    restore_request = {
        "DBInstanceIdentifier": TARGET_DB_IDENTIFIER,
        "DBSnapshotIdentifier": snapshot_identifier,
        "DBInstanceClass": DB_INSTANCE_CLASS,
        "DBSubnetGroupName": DB_SUBNET_GROUP,
        "VpcSecurityGroupIds": [SECURITY_GROUP_ID],
        "PubliclyAccessible": PUBLIC_ACCESS,
        "MultiAZ": MULTI_AZ,
        "CopyTagsToSnapshot": True,
        "AutoMinorVersionUpgrade": True,
    }
    if DB_PARAMETER_GROUP:
        restore_request["DBParameterGroupName"] = DB_PARAMETER_GROUP

    logger.info("Submitting restore request.")
    return dr_rds.restore_db_instance_from_db_snapshot(**restore_request)


def validate_restore():
    status = get_database_status(TARGET_DB_IDENTIFIER)
    logger.info(f"Current Status: {status}")
    return status in ["creating", "backing-up", "modifying", "available"]


def log_restore_details(snapshot):
    logger.info("---------------")
    logger.info("Disaster Recovery")
    logger.info("---------------")
    logger.info(f"Source DB : {SOURCE_DB_IDENTIFIER}")
    logger.info(f"Target DB : {TARGET_DB_IDENTIFIER}")
    logger.info(f"Snapshot : {snapshot['DBSnapshotIdentifier']}")
    logger.info(f"Created : {snapshot['SnapshotCreateTime']}")
    logger.info(f"Region : {DR_REGION}")
    logger.info("---------------")


def get_application_endpoint():
    if not ALB_NAME:
        return None
    response = elbv2.describe_load_balancers(Names=[ALB_NAME])
    return response["LoadBalancers"][0]["DNSName"]


def lambda_handler(event, context):
    logger.info("=" * 60)
    logger.info("DR Automator - Restore DB Lambda Started")
    logger.info("=" * 60)

    try:
        Config.validate()
        if database_exists(TARGET_DB_IDENTIFIER):
            status = get_database_status(TARGET_DB_IDENTIFIER)
            endpoint = get_database_endpoint(TARGET_DB_IDENTIFIER)
            logger.warning(f"Target database '{TARGET_DB_IDENTIFIER}' already exists.")
            return response(
                200,
                "Target database already exists.",
                {"database": TARGET_DB_IDENTIFIER, "status": status, "endpoint": endpoint},
            )

        latest_snapshot = get_latest_snapshot()
        log_restore_details(latest_snapshot)
        restore_database(latest_snapshot)

        if not validate_restore():
            raise Exception("Restore request was submitted but validation failed.")

        logger.info("Restore request submitted successfully.")
        application_dns = get_application_endpoint()
        return response(
            200,
            "Disaster Recovery Completed",
            {
                "snapshot": latest_snapshot["DBSnapshotIdentifier"],
                "target_database": TARGET_DB_IDENTIFIER,
                "region": DR_REGION,
                "status": "creating",
                "application_url": f"http://{application_dns}" if application_dns else None,
            },
        )
    except ValueError as error:
        logger.error(f"Configuration Error: {error}")
        return response(400, str(error))
    except ClientError as error:
        logger.exception("AWS Client Error")
        return response(500, error.response["Error"]["Message"])
    except Exception as error:
        logger.exception("Unhandled Exception")
        return response(500, str(error))
    finally:
        logger.info("=" * 60)
        logger.info("Restore DB Lambda Finished")
        logger.info("=" * 60)
