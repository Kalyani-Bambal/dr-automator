#!/bin/bash

set -e

FUNCTION_NAME="dr-automator-restore-db"
REGION="ap-southeast-1"

echo "========================================="
echo "Deploying Lambda"
echo "========================================="

aws lambda update-function-code \
    --function-name ${FUNCTION_NAME} \
    --zip-file fileb://function.zip \
    --region ${REGION}

echo ""
echo "Deployment completed successfully."