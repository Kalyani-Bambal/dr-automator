#!/bin/bash

set -e

##############################################################
# DR AUTOMATOR - LAMBDA DEPLOYMENT SCRIPT
##############################################################

PRIMARY_REGION="ap-south-1"
DR_REGION="ap-southeast-1"

FUNCTION_NAME="dr-automator-restore-db"

LAMBDA_DIR="../lambda/restore-db"
ZIP_FILE="restore-db.zip"

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
# Package Lambda
##############################################################

info "Packaging Lambda..."

cd "$LAMBDA_DIR"

rm -f "$ZIP_FILE"

zip -r "$ZIP_FILE" . >/dev/null

pass "Lambda package created"

##############################################################
# Deploy Lambda
##############################################################

info "Uploading Lambda..."

aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file fileb://"$ZIP_FILE" \
    --region "$DR_REGION" >/dev/null

pass "Lambda code uploaded"

##############################################################
# Wait
##############################################################

info "Waiting for deployment..."

aws lambda wait function-updated \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION"

pass "Deployment completed"

##############################################################
# Update Environment Variables
##############################################################

info "Updating Environment Variables..."

aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --environment 'Variables={
ALB_NAME=k8s-drautoma-drautoma-c17333964c,
DB_INSTANCE_CLASS=db.t3.micro,
DB_SUBNET_GROUP=dr-automator-dev-db-subnet-dr,
DR_REGION=ap-southeast-1,
MULTI_AZ=false,
PUBLIC_ACCESS=false,
SECURITY_GROUP_ID=sg-0a218e55c060df98e,
SOURCE_DB_IDENTIFIER=dr-automator-primary-db,
TARGET_DB_IDENTIFIER=dr-automator-dr-db,
KMS_KEY_ID=arn:aws:kms:ap-southeast-1:677078406480:key/f87b5c0e-22ba-4e79-bd2a-25b21570d3de
}' >/dev/null

aws lambda wait function-updated \
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
    --query Version \
    --output text)

pass "Published Version : $VERSION"

##############################################################
# Create Function URL (if missing)
##############################################################

info "Checking Function URL..."

URL=$(aws lambda get-function-url-config \
    --function-name "$FUNCTION_NAME" \
    --region "$DR_REGION" \
    --query FunctionUrl \
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
        --query FunctionUrl \
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

echo
echo "========================================================="
echo "          LAMBDA DEPLOYMENT SUCCESSFUL"
echo "========================================================="
echo

echo "Function Name : $FUNCTION_NAME"
echo "Region        : $DR_REGION"
echo "Version       : $VERSION"
echo "Function URL  : $URL"

echo