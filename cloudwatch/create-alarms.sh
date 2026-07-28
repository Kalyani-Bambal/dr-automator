#!/bin/bash

set -e

REGION="ap-south-1"

echo "Creating Lambda Errors Alarm..."

aws cloudwatch put-metric-alarm \
    --cli-input-json file://lambda-errors-alarm.json \
    --region ${REGION}

echo "Creating Lambda Duration Alarm..."

aws cloudwatch put-metric-alarm \
    --cli-input-json file://lambda-duration-alarm.json \
    --region ap-southeast-1

echo "Creating RDS CPU Alarm..."

aws cloudwatch put-metric-alarm \
    --cli-input-json file://rds-cpu-alarm.json \
    --region ${REGION}

echo "Creating RDS Storage Alarm..."

aws cloudwatch put-metric-alarm \
    --cli-input-json file://rds-storage-alarm.json \
    --region ${REGION}

echo "Creating RDS Connections Alarm..."

aws cloudwatch put-metric-alarm \
    --cli-input-json file://rds-connections-alarm.json \
    --region ${REGION}

echo ""
echo "All CloudWatch alarms created successfully."