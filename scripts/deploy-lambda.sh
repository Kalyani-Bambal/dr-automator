
#!/bin/bash

set -euo pipefail

##############################################################
# DR AUTOMATOR - LAMBDA DEPLOYMENT SCRIPT
##############################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PRIMARY_REGION="${PRIMARY_REGION:-ap-south-1}"
DR_REGION="${DR_REGION:-ap-southeast-1}"
FUNCTION_NAME="${FUNCTION_NAME:-dr-automator-restore-db}"
ROLE_NAME="${ROLE_NAME:-dr-automator-restore-db-role}"
LAMBDA_DIR="${REPO_ROOT}/lambda/restore-db"
ZIP_FILE="${SCRIPT_DIR}/restore-db.zip"
SECURITY_GROUP_NAME="${SECURITY_GROUP_NAME:-dr-automator-dev-mysql-dr-sg}"
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}}"

##############################################################
# Colors
##############################################################

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

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

##############################################################
# Start
##############################################################

echo
echo "========================================================="
echo "      DR AUTOMATOR - LAMBDA DEPLOYMENT"
echo "========================================================="
echo

##############################################################
# Check AWS CLI
##############################################################

command -v aws >/dev/null || fail "AWS CLI not installed"

##############################################################
# Check zip
##############################################################

command -v zip >/dev/null || fail "zip command not installed"

##############################################################
# Get DR RDS Security Group Automatically
##############################################################

info "Getting DR RDS Security Group ID..."

SECURITY_GROUP_ID=$(aws ec2 describe-security-groups \
    --region "$DR_REGION" \
    --filters "Name=group-name,Values=$SECURITY_GROUP_NAME" \
    --query "SecurityGroups[0].GroupId" \
    --output text)

if [ -z "$SECURITY_GROUP_ID" ] || [ "$SECURITY_GROUP_ID" = "None" ]; then
    fail "Security Group not found: $SECURITY_GROUP_NAME"
fi

pass "Security Group found: $SECURITY_GROUP_ID"

##############################################################
# Package Lambda
##############################################################

info "Packaging Lambda..."

cd "$LAMBDA_DIR" || fail "Lambda directory not found: $LAMBDA_DIR"

rm -f "$ZIP_FILE"

zip -r "$ZIP_FILE" . >/dev/null

cd "$SCRIPT_DIR" || fail "Could not return to scripts directory"

pass "Lambda package created"

##############################################################
# Ensure execution role exists
##############################################################

ensure_lambda_role() {
    if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
        return 0
    fi

    info "Creating Lambda execution role: $ROLE_NAME"

    aws iam create-role \
        --role-name "$ROLE_NAME" \
        --assume-role-policy-document '{
            "Version": "2012-10-17",
            "Statement": [{
                "Effect": "Allow",
                "Principal": {"Service": "lambda.amazonaws.com"},
                "Action": "sts:AssumeRole"
            }]
        }' >/dev/null

    aws iam put-role-policy \
        --role-name "$ROLE_NAME" \
        --policy-name "dr-automator-restore-db-policy" \
        --policy-document '{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "logs:CreateLogGroup",
                        "logs:CreateLogStream",
                        "logs:PutLogEvents"
                    ],
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "rds:DescribeDBInstances",
                        "rds:DescribeDBSnapshots",
                        "rds:RestoreDBInstanceFromDBSnapshot"
                    ],
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "elasticloadbalancing:DescribeLoadBalancers"
                    ],
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "kms:DescribeKey",
                        "kms:Decrypt",
                        "kms:Encrypt",
                        "kms:GenerateDataKey"
                    ],
                    "Resource": "*"
                },
                {
                    "Effect": "Allow",
                    "Action": [
                        "ec2:DescribeSecurityGroups",
                        "ec2:DescribeSubnets",
                        "ec2:DescribeVpcs"
                    ],
                    "Resource": "*"
                }
            ]
        }' >/dev/null

    pass "Lambda role ready: $ROLE_ARN"
}

ensure_lambda_role

##############################################################
# Deploy Lambda
##############################################################

info "Checking if Lambda function exists..."

if aws lambda get-function --function-name "$FUNCTION_NAME" --region "$DR_REGION" >/dev/null 2>&1; then
    info "Updating existing Lambda code..."
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$ZIP_FILE" \
        --region "$DR_REGION" >/dev/null
else
    info "Creating Lambda function: $FUNCTION_NAME"
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime python3.11 \
        --handler lambda_function.lambda_handler \
        --zip-file "fileb://$ZIP_FILE" \
        --role "$ROLE_ARN" \
        --timeout 300 \
        --memory-size 512 \
        --region "$DR_REGION" >/dev/null
fi

pass "Lambda code uploaded"

##############################################################
# Wait for Code Deployment
##############################################################

info "Waiting for deployment..."

aws lambda wait function-active \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION"

pass "Deployment completed"

##############################################################
# Update Environment Variables
##############################################################

KMS_KEY_ID="${KMS_KEY_ID:-$(aws kms describe-key --region "$DR_REGION" --key-id alias/dr-automator-dev-dr-kms --query 'KeyMetadata.Arn' --output text 2>/dev/null || aws kms describe-key --region "$DR_REGION" --key-id alias/dr-automator-dev-kms --query 'KeyMetadata.Arn' --output text 2>/dev/null || true)}"

if [ -z "$KMS_KEY_ID" ]; then
    warn "KMS key alias not found; set KMS_KEY_ID manually with environment variable."
    KMS_KEY_ID="arn:aws:kms:${DR_REGION}:${AWS_ACCOUNT_ID}:alias/dr-automator-dev-dr-kms"
fi

info "Updating Environment Variables..."

aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --environment "Variables={
ALB_NAME=k8s-drautoma-drautoma-c17333964c,
DB_INSTANCE_CLASS=db.t3.micro,
DB_SUBNET_GROUP=dr-automator-dev-db-subnet-dr,
DR_REGION=$DR_REGION,
MULTI_AZ=false,
PUBLIC_ACCESS=false,
SECURITY_GROUP_ID=$SECURITY_GROUP_ID,
SOURCE_DB_IDENTIFIER=dr-automator-primary-db,
TARGET_DB_IDENTIFIER=dr-automator-dr-db,
KMS_KEY_ID=$KMS_KEY_ID
}" >/dev/null

info "Waiting for configuration update..."

aws lambda wait function-active \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION"

pass "Environment variables updated"

##############################################################
# Publish Version
##############################################################

info "Publishing Version..."

VERSION=$(aws lambda publish-version \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --query "Version" \
    --output text)

pass "Published Version : $VERSION"

##############################################################
# Create Function URL (if missing)
##############################################################

info "Checking Function URL..."

URL=$(aws lambda get-function-url-config \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --query "FunctionUrl" \
    --output text 2>/dev/null || true)

if [ -z "$URL" ] || [ "$URL" = "None" ]; then

    info "Creating Function URL..."

    aws lambda create-function-url-config \
        --function-name "$FUNCTION_NAME" \
        --region "$DR_REGION" \
        --auth-type NONE >/dev/null

    URL=$(aws lambda get-function-url-config \
        --function-name "$FUNCTION_NAME" \
        --region "$DR_REGION" \
        --query "FunctionUrl" \
        --output text)
fi

pass "Function URL Ready"

echo
echo "URL : $URL"
echo

##############################################################
# Verify Deployment
##############################################################

info "Verifying Deployment..."

aws lambda get-function \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" >/dev/null

pass "Lambda deployment verified"

##############################################################
# Verify Security Group
##############################################################

info "Verifying Lambda Security Group..."

CURRENT_SG=$(aws lambda get-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --query "Environment.Variables.SECURITY_GROUP_ID" \
    --output text)

if [ "$CURRENT_SG" = "$SECURITY_GROUP_ID" ]; then
    pass "Lambda Security Group verified: $CURRENT_SG"
else
    fail "Security Group verification failed. Expected: $SECURITY_GROUP_ID, Found: $CURRENT_SG"
fi

##############################################################
# Success Summary
##############################################################

echo
echo "========================================================="
echo "          LAMBDA DEPLOYMENT SUCCESSFUL"
echo "========================================================="
echo

echo "Function Name      : $FUNCTION_NAME"
echo "Region             : $DR_REGION"
echo "Security Group     : $SECURITY_GROUP_ID"
echo "Version            : $VERSION"
echo "Function URL       : $URL"
echo
