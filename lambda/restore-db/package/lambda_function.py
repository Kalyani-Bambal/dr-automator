import os
import json
import logging
import time
from datetime import datetime, timezone

import boto3
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

PRIMARY_REGION = os.environ.get("PRIMARY_REGION", "ap-south-1")
DR_REGION = os.environ["DR_REGION"]

SOURCE_DB_IDENTIFIER = os.environ["SOURCE_DB_IDENTIFIER"]
TARGET_DB_IDENTIFIER = os.environ["TARGET_DB_IDENTIFIER"]
DB_INSTANCE_CLASS = os.environ["DB_INSTANCE_CLASS"]
DB_SUBNET_GROUP = os.environ["DB_SUBNET_GROUP"]
SECURITY_GROUP_ID = os.environ["SECURITY_GROUP_ID"]
KMS_KEY_ID = os.environ.get("KMS_KEY_ID")

source_rds = boto3.client("rds", region_name=PRIMARY_REGION)
dr_rds = boto3.client("rds", region_name=DR_REGION)

def lambda_handler(event, context):
    logger.info("Disaster Recovery Started")

    import os
import json
import logging
from datetime import datetime

import boto3
from botocore.exceptions import ClientError

# ---------------------------------------------------------------------
# Logging Configuration
# ---------------------------------------------------------------------

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ---------------------------------------------------------------------
# Environment Variables
# ---------------------------------------------------------------------

from config import Config

DR_REGION = Config.DR_REGION
SOURCE_DB_IDENTIFIER = Config.SOURCE_DB_IDENTIFIER
TARGET_DB_IDENTIFIER = Config.TARGET_DB_IDENTIFIER

DB_INSTANCE_CLASS = Config.DB_INSTANCE_CLASS
DB_SUBNET_GROUP = Config.DB_SUBNET_GROUP
SECURITY_GROUP_ID = Config.SECURITY_GROUP_ID

DB_PARAMETER_GROUP = Config.DB_PARAMETER_GROUP
PUBLIC_ACCESS = Config.PUBLIC_ACCESS
MULTI_AZ = Config.MULTI_AZ

# ---------------------------------------------------------------------
# AWS Client
# ---------------------------------------------------------------------

rds = boto3.client(
    "rds",
    region_name=DR_REGION
)

# ---------------------------------------------------------------------
# Validate Configuration
# ---------------------------------------------------------------------

def validate_configuration():
    """
    Validates all required environment variables.
    """

    required = {
        "DR_REGION": DR_REGION,
        "SOURCE_DB_IDENTIFIER": SOURCE_DB_IDENTIFIER,
        "TARGET_DB_IDENTIFIER": TARGET_DB_IDENTIFIER,
        "DB_INSTANCE_CLASS": DB_INSTANCE_CLASS,
        "DB_SUBNET_GROUP": DB_SUBNET_GROUP,
        "SECURITY_GROUP_ID": SECURITY_GROUP_ID,
    }

    missing = []

    for key, value in required.items():
        if value is None or value == "":
            missing.append(key)

    if missing:
        raise ValueError(
            f"Missing environment variables: {', '.join(missing)}"
        )

# ---------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------

def response(status_code, message, data=None):
    """
    Standard JSON response.
    """

    body = {
        "message": message,
        "timestamp": datetime.utcnow().isoformat()
    }

    if data:
        body["data"] = data

    return {
        "statusCode": status_code,
        "body": json.dumps(body)
    }

# ---------------------------------------------------------------------
# Get Latest Snapshot
# ---------------------------------------------------------------------

def get_latest_snapshot():
    """
    Returns the newest available manual snapshot.
    """

    logger.info("Searching for latest manual snapshot...")

    try:

        snapshots = rds.describe_db_snapshots(
            SnapshotType="manual"
        )["DBSnapshots"]

    except ClientError as error:

        logger.error(error)

        raise

    snapshots = [
        s
        for s in snapshots
        if s["Status"] == "available"
    ]

    if len(snapshots) == 0:

        raise Exception(
            "No available manual snapshots found."
        )

    snapshots.sort(
        key=lambda x: x["SnapshotCreateTime"],
        reverse=True
    )

    latest = snapshots[0]

    logger.info(
        f"Latest Snapshot: {latest['DBSnapshotIdentifier']}"
    )

    return latest

# ---------------------------------------------------------------------
# Check if Target Database Already Exists
# ---------------------------------------------------------------------

def database_exists(db_identifier):
    """
    Returns True if the DB exists, otherwise False.
    """

    logger.info(f"Checking database: {db_identifier}")

    try:
        rds.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )

        logger.info("Database already exists.")

        return True

    except ClientError as error:

        error_code = error.response["Error"]["Code"]

        logger.info(f"Received error code: {error_code}")

        if error_code in (
            "DBInstanceNotFound",
            "DBInstanceNotFoundFault",
        ):
            logger.info("Database does not exist.")
            return False

        raise


# ---------------------------------------------------------------------
# Restore Database From Snapshot
# ---------------------------------------------------------------------

def restore_database(snapshot):

    snapshot_identifier = snapshot["DBSnapshotIdentifier"]

    logger.info(
        f"Starting restore using snapshot: {snapshot_identifier}"
    )

    restore_request = {

        "DBInstanceIdentifier": TARGET_DB_IDENTIFIER,

        "DBSnapshotIdentifier": snapshot_identifier,

        "DBInstanceClass": DB_INSTANCE_CLASS,

        "DBSubnetGroupName": DB_SUBNET_GROUP,

        "VpcSecurityGroupIds": [
            SECURITY_GROUP_ID
        ],

        "PubliclyAccessible": PUBLIC_ACCESS,

        "MultiAZ": MULTI_AZ,

        "CopyTagsToSnapshot": True,

        "AutoMinorVersionUpgrade": True
    }

    if DB_PARAMETER_GROUP:

        restore_request[
            "DBParameterGroupName"
        ] = DB_PARAMETER_GROUP

    logger.info("Submitting restore request.")

    response = rds.restore_db_instance_from_db_snapshot(
        **restore_request
    )

    logger.info("Restore request submitted successfully.")

    return response


# ---------------------------------------------------------------------
# Get Database Status
# ---------------------------------------------------------------------

def get_database_status(db_identifier):

    try:

        response = rds.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )

        return response["DBInstances"][0]["DBInstanceStatus"]

    except ClientError:

        return "UNKNOWN"


# ---------------------------------------------------------------------
# Get Endpoint
# ---------------------------------------------------------------------

def get_database_endpoint(db_identifier):

    try:

        response = rds.describe_db_instances(
            DBInstanceIdentifier=db_identifier
        )

        endpoint = response["DBInstances"][0].get(
            "Endpoint",
            {}
        )

        return endpoint.get("Address")

    except ClientError:

        return None


# ---------------------------------------------------------------------
# Restore Validation
# ---------------------------------------------------------------------

def validate_restore():

    logger.info("Validating restore request.")

    status = get_database_status(
        TARGET_DB_IDENTIFIER
    )

    logger.info(f"Current Status: {status}")

    if status in [

        "creating",

        "backing-up",

        "modifying",

        "available"

    ]:

        return True

    return False


# ---------------------------------------------------------------------
# Log Restore Information
# ---------------------------------------------------------------------

def log_restore_details(snapshot):

    logger.info("---------------")

    logger.info("Disaster Recovery")

    logger.info("---------------")

    logger.info(
        f"Source DB : {SOURCE_DB_IDENTIFIER}"
    )

    logger.info(
        f"Target DB : {TARGET_DB_IDENTIFIER}"
    )

    logger.info(
        f"Snapshot : {snapshot['DBSnapshotIdentifier']}"
    )

    logger.info(
        f"Created : {snapshot['SnapshotCreateTime']}"
    )

    logger.info(
        f"Region : {DR_REGION}"
    )

    logger.info("---------------")
    
    # ---------------------------------------------------------------------
# Lambda Handler
# ---------------------------------------------------------------------

def lambda_handler(event, context):
    """
    Entry point for the Restore DB Lambda.
    """

    logger.info("=" * 60)
    logger.info("DR Automator - Restore DB Lambda Started")
    logger.info("=" * 60)

    try:

        # Validate configuration
        Config.validate()

        # Check if target DB already exists
        if database_exists(TARGET_DB_IDENTIFIER):

            status = get_database_status(TARGET_DB_IDENTIFIER)

            endpoint = get_database_endpoint(TARGET_DB_IDENTIFIER)

            logger.warning(
                f"Target database '{TARGET_DB_IDENTIFIER}' already exists."
            )

            return response(
                200,
                "Target database already exists.",
                {
                    "database": TARGET_DB_IDENTIFIER,
                    "status": status,
                    "endpoint": endpoint
                }
            )

        # Get latest manual snapshot
        latest_snapshot = get_latest_snapshot()

        log_restore_details(latest_snapshot)

        # Start restore
        restore_database(latest_snapshot)

        # Validate request accepted
        if not validate_restore():

            raise Exception(
                "Restore request was submitted but validation failed."
            )

        logger.info("Restore request submitted successfully.")

        return response(
            200,
            "Database restore initiated successfully.",
            {
                "snapshot": latest_snapshot["DBSnapshotIdentifier"],
                "target_database": TARGET_DB_IDENTIFIER,
                "region": DR_REGION,
                "status": "creating"
            }
        )

    except ValueError as error:

        logger.error(f"Configuration Error: {error}")

        return response(
            400,
            str(error)
        )

    except ClientError as error:

        logger.exception("AWS Client Error")

        return response(
            500,
            error.response["Error"]["Message"]
        )

    except Exception as error:

        logger.exception("Unhandled Exception")

        return response(
            500,
            str(error)
        )

    finally:

        logger.info("=" * 60)
        logger.info("Restore DB Lambda Finished")
        logger.info("=" * 60)