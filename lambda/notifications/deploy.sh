#!/bin/bash
set -euo pipefail

REGION="ap-south-1"
FUNCTION_NAME="dr-automator-notifications"
ZIP_FILE="notifications.zip"
ROLE_ARN="arn:aws:iam::677078406480:role/dr-automator-restore-db-role"
SNS_TOPIC_ARN="arn:aws:sns:ap-south-1:677078406480:dr-automator-alerts"

# If WEBHOOK_TOKEN empty, generate one
WEBHOOK_TOKEN=${WEBHOOK_TOKEN:-}
if [ -z "$WEBHOOK_TOKEN" ]; then
  WEBHOOK_TOKEN=$(openssl rand -hex 16)
  echo "Generated WEBHOOK_TOKEN: $WEBHOOK_TOKEN"
fi

echo "Packaging lambda..."
rm -f ${ZIP_FILE}
zip -r ${ZIP_FILE} lambda_function.py || true

echo "Checking if function exists..."
if aws lambda get-function --function-name ${FUNCTION_NAME} --region ${REGION} >/dev/null 2>&1; then
  echo "Updating existing function code..."
  aws lambda update-function-code --function-name ${FUNCTION_NAME} --zip-file fileb://${ZIP_FILE} --region ${REGION}
  aws lambda update-function-configuration --function-name ${FUNCTION_NAME} --environment "Variables={SNS_TOPIC_ARN=${SNS_TOPIC_ARN},WEBHOOK_TOKEN=${WEBHOOK_TOKEN}}" --region ${REGION}
else
  echo "Creating function ${FUNCTION_NAME}..."
  aws lambda create-function \
    --function-name ${FUNCTION_NAME} \
    --runtime python3.11 \
    --handler lambda_function.lambda_handler \
    --zip-file fileb://${ZIP_FILE} \
    --role ${ROLE_ARN} \
    --environment "Variables={SNS_TOPIC_ARN=${SNS_TOPIC_ARN},WEBHOOK_TOKEN=${WEBHOOK_TOKEN}}" \
    --region ${REGION}
fi

echo "Creating (or updating) Function URL with no auth for webhook forwarding..."
if aws lambda get-function-url-config --function-name ${FUNCTION_NAME} --region ${REGION} >/dev/null 2>&1; then
  aws lambda update-function-url-config --function-name ${FUNCTION_NAME} --auth-type NONE --cors "AllowOrigins=[*]" --region ${REGION}
else
  aws lambda create-function-url-config --function-name ${FUNCTION_NAME} --auth-type NONE --cors "AllowOrigins=[*]" --region ${REGION}
fi

URL=$(aws lambda get-function-url-config --function-name ${FUNCTION_NAME} --query 'FunctionUrl' --output text --region ${REGION})
echo "Function URL: ${URL}"

echo "Ensure API callers are allowed (none used here) and confirm the environment SNS_TOPIC_ARN is set to: ${SNS_TOPIC_ARN}"

echo "Done."
