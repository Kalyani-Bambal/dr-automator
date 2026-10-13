#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-ap-south-1}"
STATE_BUCKET="${TF_STATE_BUCKET:-dr-automator-terraform-state-${AWS_REGION}}"
LOCK_TABLE="${TF_STATE_LOCK_TABLE:-dr-automator-terraform-state-lock}"

aws sts get-caller-identity >/dev/null

if ! aws s3api head-bucket --bucket "${STATE_BUCKET}" --region "${AWS_REGION}" >/dev/null 2>&1; then
  if [ "${AWS_REGION}" = "us-east-1" ]; then
    aws s3api create-bucket --bucket "${STATE_BUCKET}" --region "${AWS_REGION}" >/dev/null
  else
    aws s3api create-bucket \
      --bucket "${STATE_BUCKET}" \
      --region "${AWS_REGION}" \
      --create-bucket-configuration "LocationConstraint=${AWS_REGION}" >/dev/null
  fi
fi

aws s3api put-bucket-versioning \
  --bucket "${STATE_BUCKET}" \
  --versioning-configuration Status=Enabled \
  --region "${AWS_REGION}" >/dev/null

aws s3api put-bucket-encryption \
  --bucket "${STATE_BUCKET}" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
  --region "${AWS_REGION}" >/dev/null

aws s3api put-public-access-block \
  --bucket "${STATE_BUCKET}" \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  --region "${AWS_REGION}" >/dev/null

aws dynamodb create-table \
  --table-name "${LOCK_TABLE}" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region "${AWS_REGION}" >/dev/null 2>&1 || true

echo "[INFO] Terraform remote state ready: s3://${STATE_BUCKET} (lock table: ${LOCK_TABLE})"
