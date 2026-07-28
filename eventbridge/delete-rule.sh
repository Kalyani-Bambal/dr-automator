#!/bin/bash

set -e

REGION="ap-southeast-1"

RULE_NAME="dr-automator-restore-db-rule"

echo "Removing Target..."

aws events remove-targets \
    --rule ${RULE_NAME} \
    --ids RestoreDBLambda \
    --region ${REGION}

echo ""
echo "Deleting Rule..."

aws events delete-rule \
    --name ${RULE_NAME} \
    --region ${REGION}

echo ""
echo "Rule Deleted Successfully"