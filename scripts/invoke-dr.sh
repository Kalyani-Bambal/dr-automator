#!/bin/bash

set -euo pipefail

##############################################################
# DR AUTOMATOR - INVOKE DR LAMBDA
##############################################################

DR_REGION="ap-southeast-1"
FUNCTION_NAME="dr-automator-restore-db"

PAYLOAD_FILE="event.json"
OUTPUT_FILE="response.json"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
NC="\033[0m"

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    exit 1
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

echo
echo "=============================================================="
echo "          DR AUTOMATOR - INVOKE DR LAMBDA"
echo "=============================================================="
echo

##############################################################
# Check AWS CLI
##############################################################

command -v aws >/dev/null || fail "AWS CLI is not installed"

##############################################################
# Check Lambda
##############################################################

info "Checking Lambda Function..."

aws lambda get-function \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" >/dev/null

pass "Lambda Function Found"

##############################################################
# Create Payload
##############################################################

info "Creating Payload..."

cat > "$PAYLOAD_FILE" <<EOF
{
  "action": "restore"
}
EOF

pass "Payload Created"

##############################################################
# Invoke Lambda
##############################################################

info "Invoking Lambda..."

aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --payload fileb://"$PAYLOAD_FILE" \
    --cli-binary-format raw-in-base64-out \
    "$OUTPUT_FILE"

pass "Lambda Invoked"

##############################################################
# Display Response
##############################################################

echo
echo "=============================================================="
echo "Lambda Response"
echo "=============================================================="

cat "$OUTPUT_FILE"

echo
echo

##############################################################
# Check Restore Status
##############################################################

info "Checking DR Database Status..."

STATUS=$(aws rds describe-db-instances \
    --db-instance-identifier dr-automator-dr-db \
    --region "$DR_REGION" \
    --query "DBInstances[0].DBInstanceStatus" \
    --output text 2>/dev/null || echo "NOT_FOUND")

echo "Current Status : $STATUS"

case "$STATUS" in
    available)
        pass "DR Database Available"
        ;;
    creating)
        info "DR Database is being created..."
        ;;
    restoring)
        info "DR Database is restoring..."
        ;;
    *)
        info "Current State : $STATUS"
        ;;
esac

##############################################################
# Cleanup
##############################################################

rm -f "$PAYLOAD_FILE"

echo
echo "=============================================================="
echo "             DR INVOCATION COMPLETED"
echo "=============================================================="

echo
echo "Lambda Function : $FUNCTION_NAME"
echo "Region          : $DR_REGION"
echo "Database Status : $STATUS"
echo