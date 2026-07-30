#!/bin/bash

DR_REGION="ap-southeast-1"

DB_INSTANCE="dr-automator-dr-db"

echo "======================================="
echo "Rollback to Primary"
echo "======================================="

echo ""
echo "Deleting restored DR database..."

aws rds delete-db-instance \
    --db-instance-identifier ${DB_INSTANCE} \
    --skip-final-snapshot \
    --region ${DR_REGION}

echo ""
echo "Rollback initiated."

echo ""
echo "Monitor status using:"

echo "aws rds describe-db-instances --region ${DR_REGION}"