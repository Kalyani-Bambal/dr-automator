#!/bin/bash

REGION="ap-southeast-1"

echo "======================================="
echo "Triggering Disaster Recovery"
echo "======================================="

aws lambda invoke \
    --function-name dr-automator-restore-db \
    --payload '{}' \
    --cli-binary-format raw-in-base64-out \
    response.json \
    --region ${REGION}

echo ""
echo "Lambda Response"

cat response.json