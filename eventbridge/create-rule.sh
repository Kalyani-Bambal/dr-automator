#!/bin/bash

set -e

REGION="ap-southeast-1"
ACCOUNT_ID="677078406480"

RULE_NAME="dr-automator-restore-db-rule"

FUNCTION_NAME="dr-automator-restore-db"

FUNCTION_ARN="arn:aws:lambda:${REGION}:${ACCOUNT_ID}:function:${FUNCTION_NAME}"

echo "======================================="
echo "Creating EventBridge Rule"
echo "======================================="

aws events put-rule \
    --name ${RULE_NAME} \
    --schedule-expression "rate(10 minutes)" \
    --state ENABLED \
    --region ${REGION}

echo ""
echo "Adding Lambda Target..."

aws events put-targets \
    --rule ${RULE_NAME} \
    --targets "Id"="RestoreDBLambda","Arn"="${FUNCTION_ARN}" \
    --region ${REGION}

echo ""
echo "Granting EventBridge permission..."

aws lambda add-permission \
    --function-name ${FUNCTION_NAME} \
    --statement-id eventbridge-restore-db \
    --action lambda:InvokeFunction \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:${REGION}:${ACCOUNT_ID}:rule/${RULE_NAME} \
    --region ${REGION}

echo ""
echo "EventBridge Rule Created Successfully"