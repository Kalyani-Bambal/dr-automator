#!/bin/bash

REGION="ap-southeast-1"

RULE_NAME="dr-automator-restore-db-rule"

echo "===================================="
echo "EventBridge Rule"
echo "===================================="

aws events describe-rule \
    --name ${RULE_NAME} \
    --region ${REGION}

echo ""
echo "===================================="
echo "Targets"
echo "===================================="

aws events list-targets-by-rule \
    --rule ${RULE_NAME} \
    --region ${REGION}

echo ""
echo "===================================="
echo "Lambda Permission"
echo "===================================="

aws lambda get-policy \
    --function-name dr-automator-restore-db \
    --region ${REGION}

echo ""
echo "===================================="
echo "Recent Lambda Logs"
echo "===================================="

aws logs tail /aws/lambda/dr-automator-restore-db \
    --since 10m \
    --region ${REGION}