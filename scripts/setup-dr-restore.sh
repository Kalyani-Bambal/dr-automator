#!/bin/bash

set -euo pipefail

PRIMARY_REGION="${PRIMARY_REGION:-ap-south-1}"
DR_REGION="${DR_REGION:-ap-southeast-1}"
SOURCE_SNAPSHOT="${SOURCE_SNAPSHOT:-dr-automator-dev-snapshot-20261006064102}"
TARGET_SNAPSHOT="${TARGET_SNAPSHOT:-dr-automator-dev-snapshot-singapore}"
DR_DB_ID="${DR_DB_ID:-dr-automator-dr-db}"
DB_SUBNET_GROUP="${DB_SUBNET_GROUP:-dr-automator-dev-db-subnet-dr}"
SECURITY_GROUP_ID="${SECURITY_GROUP_ID:-sg-07a13be005c925e59}"
DB_INSTANCE_CLASS="${DB_INSTANCE_CLASS:-db.t3.micro}"
KMS_KEY_ID="${KMS_KEY_ID:-arn:aws:kms:ap-southeast-1:926658607256:key/3b84ac46-b355-43ce-8f84-8823488cd566}"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

check_aws() {
  command -v aws >/dev/null 2>&1 || fail "AWS CLI is not installed"
  aws sts get-caller-identity >/dev/null 2>&1 || fail "AWS credentials are not configured"
}

wait_for_snapshot() {
  local snapshot_id="$1"
  local region="$2"
  local status

  info "Waiting for snapshot ${snapshot_id} in ${region} to become available..."
  while true; do
    status=$(aws rds describe-db-snapshots \
      --region "$region" \
      --db-snapshot-identifier "$snapshot_id" \
      --query 'DBSnapshots[0].Status' \
      --output text 2>/dev/null || echo "PENDING")

    if [ "$status" = "available" ]; then
      pass "Snapshot available: $snapshot_id"
      return 0
    fi

    echo "Current snapshot status: $status"
    sleep 15
  done
}

wait_for_db() {
  local db_id="$1"
  local region="$2"
  local status

  info "Waiting for database ${db_id} in ${region} to become available..."
  while true; do
    status=$(aws rds describe-db-instances \
      --region "$region" \
      --db-instance-identifier "$db_id" \
      --query 'DBInstances[0].DBInstanceStatus' \
      --output text 2>/dev/null || echo "PENDING")

    if [ "$status" = "available" ]; then
      pass "Database available: $db_id"
      return 0
    fi

    echo "Current DB status: $status"
    sleep 20
  done
}

echo
echo "=============================================================="
echo " DR AUTOMATOR - PREPARE DR REGION DATABASE"
echo "=============================================================="
echo

check_aws

SOURCE_SNAPSHOT_ARN=$(aws rds describe-db-snapshots \
  --region "$PRIMARY_REGION" \
  --db-snapshot-identifier "$SOURCE_SNAPSHOT" \
  --query 'DBSnapshots[0].DBSnapshotArn' \
  --output text)

info "Source region: $PRIMARY_REGION"
info "DR region: $DR_REGION"
info "Source snapshot: $SOURCE_SNAPSHOT"
info "Source snapshot ARN: $SOURCE_SNAPSHOT_ARN"
info "Target snapshot: $TARGET_SNAPSHOT"
info "DR DB identifier: $DR_DB_ID"
info "Destination KMS key: $KMS_KEY_ID"

if aws rds describe-db-instances --region "$DR_REGION" --db-instance-identifier "$DR_DB_ID" >/dev/null 2>&1; then
  status=$(aws rds describe-db-instances \
    --region "$DR_REGION" \
    --db-instance-identifier "$DR_DB_ID" \
    --query 'DBInstances[0].DBInstanceStatus' \
    --output text)
  pass "DR database already exists: $DR_DB_ID (status: $status)"
else
  info "Copying snapshot from $PRIMARY_REGION to $DR_REGION..."
  aws rds copy-db-snapshot \
    --source-db-snapshot-identifier "$SOURCE_SNAPSHOT_ARN" \
    --target-db-snapshot-identifier "$TARGET_SNAPSHOT" \
    --source-region "$PRIMARY_REGION" \
    --kms-key-id "$KMS_KEY_ID" \
    --region "$DR_REGION" >/dev/null

  pass "Snapshot copy requested"
  wait_for_snapshot "$TARGET_SNAPSHOT" "$DR_REGION"

  info "Restoring database from copied snapshot..."
  aws rds restore-db-instance-from-db-snapshot \
    --db-instance-identifier "$DR_DB_ID" \
    --db-snapshot-identifier "$TARGET_SNAPSHOT" \
    --db-instance-class "$DB_INSTANCE_CLASS" \
    --db-subnet-group-name "$DB_SUBNET_GROUP" \
    --vpc-security-group-ids "$SECURITY_GROUP_ID" \
    --no-publicly-accessible \
    --region "$DR_REGION" >/dev/null

  pass "Restore command submitted"
  wait_for_db "$DR_DB_ID" "$DR_REGION"
fi

DB_ENDPOINT=$(aws rds describe-db-instances \
  --region "$DR_REGION" \
  --db-instance-identifier "$DR_DB_ID" \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text)

DB_STATUS=$(aws rds describe-db-instances \
  --region "$DR_REGION" \
  --db-instance-identifier "$DR_DB_ID" \
  --query 'DBInstances[0].DBInstanceStatus' \
  --output text)

echo
echo "=============================================================="
echo "DR database is ready"
echo "=============================================================="
echo
printf "DB Identifier : %s\n" "$DR_DB_ID"
printf "Endpoint      : %s\n" "$DB_ENDPOINT"
printf "Status        : %s\n" "$DB_STATUS"
printf "Region        : %s\n" "$DR_REGION"
echo
pass "Singapore DR database is ready for use"
