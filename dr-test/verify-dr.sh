#!/bin/bash

PRIMARY_REGION="ap-south-1"
DR_REGION="ap-southeast-1"

DB_INSTANCE="dr-automator-dr-db"

echo "======================================="
echo "Verifying Disaster Recovery"
echo "======================================="

echo ""
echo "Checking DR Database..."

aws rds describe-db-instances \
    --db-instance-identifier ${DB_INSTANCE} \
    --region ${DR_REGION} \
    --query "DBInstances[0].DBInstanceStatus"

echo ""
echo "Retrieving Application Endpoint..."

DNS=$(aws elbv2 describe-load-balancers \
    --region ${PRIMARY_REGION} \
    --query "LoadBalancers[0].DNSName" \
    --output text)

echo ""
echo "Application URL"

echo "http://${DNS}"

echo ""
echo "Checking Health Endpoint..."

curl http://${DNS}/health

echo ""
echo ""
echo "Verification Completed."