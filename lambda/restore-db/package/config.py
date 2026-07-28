# SOURCE_DB_IDENTIFIER = "dr-automator-primary-db"

# TARGET_DB_IDENTIFIER = "dr-automator-dr-db"

# DB_INSTANCE_CLASS = "db.t3.micro"

"""
Configuration for Restore DB Lambda
"""

import os


class Config:
    """
    Reads and validates Lambda environment variables.
    """

    DR_REGION = os.getenv("DR_REGION")
    SOURCE_DB_IDENTIFIER = os.getenv("SOURCE_DB_IDENTIFIER")
    TARGET_DB_IDENTIFIER = os.getenv("TARGET_DB_IDENTIFIER")

    DB_INSTANCE_CLASS = os.getenv("DB_INSTANCE_CLASS")
    DB_SUBNET_GROUP = os.getenv("DB_SUBNET_GROUP")
    SECURITY_GROUP_ID = os.getenv("SECURITY_GROUP_ID")

    DB_PARAMETER_GROUP = os.getenv("DB_PARAMETER_GROUP")

    PUBLIC_ACCESS = (
        os.getenv("PUBLIC_ACCESS", "false").lower() == "true"
    )

    MULTI_AZ = (
        os.getenv("MULTI_AZ", "false").lower() == "true"
    )

    REQUIRED = {
        "DR_REGION": DR_REGION,
        "SOURCE_DB_IDENTIFIER": SOURCE_DB_IDENTIFIER,
        "TARGET_DB_IDENTIFIER": TARGET_DB_IDENTIFIER,
        "DB_INSTANCE_CLASS": DB_INSTANCE_CLASS,
        "DB_SUBNET_GROUP": DB_SUBNET_GROUP,
        "SECURITY_GROUP_ID": SECURITY_GROUP_ID,
    }

    @classmethod
    def validate(cls):
        """
        Validate required environment variables.
        """

        missing = []

        for key, value in cls.REQUIRED.items():
            if value is None or value == "":
                missing.append(key)

        if missing:
            raise ValueError(
                "Missing environment variables: "
                + ", ".join(missing)
            )