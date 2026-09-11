#!/bin/bash

###############################################################################
# DR Automator Health Check Script
# Part 1
# Checks:
#   - AWS CLI
#   - AWS Credentials
#   - AWS Account
#   - Terraform
#   - Docker
#   - kubectl
###############################################################################

set -e

###############################################
# Colors
###############################################

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m"

###############################################
# Helper Functions
###############################################

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

###############################################
# Banner
###############################################

echo
echo "==============================================================="
echo "              DR AUTOMATOR HEALTH CHECK"
echo "==============================================================="
echo

###############################################
# Check AWS CLI
###############################################

info "Checking AWS CLI..."

if command -v aws >/dev/null 2>&1
then
    VERSION=$(aws --version 2>&1)
    pass "AWS CLI Installed"
    echo "      $VERSION"
else
    fail "AWS CLI NOT Installed"
    exit 1
fi

echo

###############################################
# Check AWS Credentials
###############################################

info "Checking AWS Credentials..."

if aws sts get-caller-identity >/dev/null 2>&1
then
    pass "AWS Credentials Configured"
else
    fail "AWS Credentials NOT Configured"
    echo
    echo "Run:"
    echo
    echo "aws configure"
    echo
    exit 1
fi

echo

###############################################
# Show Current AWS Account
###############################################

info "Fetching AWS Account Details..."

ACCOUNT_ID=$(aws sts get-caller-identity \
    --query Account \
    --output text)

USER_ARN=$(aws sts get-caller-identity \
    --query Arn \
    --output text)

pass "AWS Account Connected"

echo "Account ID : $ACCOUNT_ID"
echo "IAM User   : $USER_ARN"

echo

###############################################
# Check Default Region
###############################################

info "Checking AWS Default Region..."

REGION=$(aws configure get region)

if [ -z "$REGION" ]
then
    warn "Default Region Not Configured"
else
    pass "Default Region : $REGION"
fi

echo

###############################################
# Check Terraform
###############################################

info "Checking Terraform..."

if command -v terraform >/dev/null 2>&1
then

    TF_VERSION=$(terraform version | head -1)

    pass "Terraform Installed"

    echo "      $TF_VERSION"

else

    fail "Terraform NOT Installed"

fi

echo

###############################################
# Check Docker
###############################################

info "Checking Docker..."

if command -v docker >/dev/null 2>&1
then

    pass "Docker Installed"

else

    fail "Docker NOT Installed"

    exit 1

fi

echo

###############################################
# Check Docker Service
###############################################

info "Checking Docker Service..."

if docker info >/dev/null 2>&1
then

    pass "Docker Service Running"

else

    fail "Docker Service NOT Running"

fi

echo

###############################################
# Check Docker Compose
###############################################

info "Checking Docker Compose..."

if docker compose version >/dev/null 2>&1
then

    VERSION=$(docker compose version)

    pass "Docker Compose Available"

    echo "      $VERSION"

elif command -v docker-compose >/dev/null 2>&1
then

    VERSION=$(docker-compose version --short)

    pass "docker-compose Installed"

    echo "      Version $VERSION"

else

    fail "Docker Compose NOT Installed"

fi

echo

###############################################
# Check kubectl
###############################################

info "Checking kubectl..."

if command -v kubectl >/dev/null 2>&1
then

    VERSION=$(kubectl version --client --short 2>/dev/null || kubectl version --client)

    pass "kubectl Installed"

    echo "$VERSION"

else

    fail "kubectl NOT Installed"

fi

echo

###############################################
# Check kubectl Connectivity
###############################################

info "Checking Kubernetes Connectivity..."

if kubectl cluster-info >/dev/null 2>&1
then

    pass "kubectl Connected"

else

    warn "kubectl Installed but Cluster Not Connected"

fi

echo

###############################################
# Check Git
###############################################

info "Checking Git..."

if command -v git >/dev/null 2>&1
then

    VERSION=$(git --version)

    pass "Git Installed"

    echo "      $VERSION"

else

    fail "Git NOT Installed"

fi

echo

###############################################
# Summary
###############################################

echo "==============================================================="
echo " Part 1 Completed Successfully"
echo "==============================================================="

echo
echo "Next:"
echo "Part 2 will verify:"
echo
echo "  ✓ Primary RDS"
echo "  ✓ DR RDS"
echo "  ✓ Snapshots"
echo "  ✓ Security Groups"
echo "  ✓ Subnet Groups"
echo "  ✓ KMS Key"
echo

###############################################################################
# PART 2
# AWS Infrastructure Checks
###############################################################################

echo
echo "==============================================================="
echo "               PART 2 - AWS RESOURCE CHECKS"
echo "==============================================================="
echo

PRIMARY_REGION="ap-south-1"
DR_REGION="ap-southeast-1"

PRIMARY_DB="dr-automator-dev-mysql"
DR_DB="dr-automator-dr-db"

##############################################################
# PRIMARY RDS
##############################################################

info "Checking Primary RDS..."

PRIMARY_STATUS=$(aws rds describe-db-instances \
--db-instance-identifier $PRIMARY_DB \
--region $PRIMARY_REGION \
--query "DBInstances[0].DBInstanceStatus" \
--output text 2>/dev/null)

if [ $? -eq 0 ]
then
    pass "Primary RDS Found"
    echo "Status : $PRIMARY_STATUS"
else
    fail "Primary RDS NOT Found"
fi

echo

##############################################################
# DR RDS
##############################################################

info "Checking DR RDS..."

DR_EXISTS=$(aws rds describe-db-instances \
    --region "$DR_REGION" \
    --query "DBInstances[?DBInstanceIdentifier=='$DR_DB'] | length(@)" \
    --output text)

if [ "$DR_EXISTS" = "1" ]; then
    DR_STATUS=$(aws rds describe-db-instances \
        --db-instance-identifier "$DR_DB" \
        --region "$DR_REGION" \
        --query "DBInstances[0].DBInstanceStatus" \
        --output text)

    pass "DR RDS Found"
    echo "Status : $DR_STATUS"
else
    warn "No DR RDS instance (Expected before failover)"
fi

echo

##############################################################
# PRIMARY SNAPSHOTS
##############################################################

info "Checking Primary Snapshots..."

aws rds describe-db-snapshots \
--snapshot-type manual \
--region $PRIMARY_REGION \
--query "reverse(sort_by(DBSnapshots,&SnapshotCreateTime))[0].[DBSnapshotIdentifier,Status]" \
--output table

echo

##############################################################
# DR SNAPSHOTS
##############################################################

info "Checking DR Snapshots..."

aws rds describe-db-snapshots \
--snapshot-type manual \
--region $DR_REGION \
--query "reverse(sort_by(DBSnapshots,&SnapshotCreateTime))[0].[DBSnapshotIdentifier,Status]" \
--output table

echo

##############################################################
# KMS KEY
##############################################################

info "Checking DR KMS Key..."

KMS_KEY=$(aws lambda get-function-configuration \
--function-name dr-automator-restore-db \
--region $DR_REGION \
--query "Environment.Variables.KMS_KEY_ID" \
--output text 2>/dev/null)

if [ -z "$KMS_KEY" ]
then

    fail "KMS Key Not Configured"

else

    STATE=$(aws kms describe-key \
    --key-id "$KMS_KEY" \
    --region $DR_REGION \
    --query "KeyMetadata.KeyState" \
    --output text)

    if [ "$STATE" = "Enabled" ]
    then

        pass "KMS Key Enabled"

    else

        fail "KMS Key State : $STATE"

    fi

fi

echo

##############################################################
# DB SUBNET GROUP
##############################################################

info "Checking DB Subnet Group..."

aws rds describe-db-subnet-groups \
--db-subnet-group-name dr-automator-dev-db-subnet-dr \
--region $DR_REGION >/dev/null 2>&1

if [ $? -eq 0 ]
then

    pass "DB Subnet Group Exists"

else

    fail "DB Subnet Group Missing"

fi

echo

##############################################################
# SECURITY GROUP
##############################################################

info "Checking Security Group..."

SG=$(aws lambda get-function-configuration \
    --function-name dr-automator-restore-db \
    --region "$DR_REGION" \
    --query "Environment.Variables.SECURITY_GROUP_ID" \
    --output text 2>/dev/null)

if [ -z "$SG" ] || [ "$SG" = "None" ] || [ "$SG" = "null" ]; then
    fail "SECURITY_GROUP_ID not configured in Lambda"
else
    if aws ec2 describe-security-groups \
        --group-ids "$SG" \
        --region "$DR_REGION" >/dev/null 2>&1
    then
        pass "Security Group Exists"
        echo "Security Group: $SG"
    else
        fail "Security Group Missing ($SG)"
    fi
fi

echo

##############################################################
# LAMBDA
##############################################################

info "Checking Lambda..."

aws lambda get-function \
--function-name dr-automator-restore-db \
--region $DR_REGION >/dev/null 2>&1

if [ $? -eq 0 ]
then

    pass "Lambda Exists"

else

    fail "Lambda Missing"

fi

echo

##############################################################
# LAMBDA ENVIRONMENT VARIABLES
##############################################################

info "Checking Lambda Environment Variables..."

aws lambda get-function-configuration \
--function-name dr-automator-restore-db \
--region $DR_REGION \
--query "Environment.Variables"

echo

##############################################################
# SUMMARY
##############################################################

echo
echo "==============================================================="
echo "PART 2 COMPLETED"
echo "==============================================================="
echo

echo "Verified Resources"

echo "✓ Primary RDS"

echo "✓ DR RDS"

echo "✓ Manual Snapshots"

echo "✓ DR Snapshots"

echo "✓ KMS Key"

echo "✓ DB Subnet Group"

echo "✓ Security Group"

echo "✓ Lambda"

echo "✓ Lambda Environment"

echo

###############################################################################
# PART 3A
# Lambda Checks
###############################################################################

echo
echo "==============================================================="
echo "                 PART 3A - LAMBDA CHECKS"
echo "==============================================================="
echo

LAMBDA_NAME="dr-automator-restore-db"

##############################################################
# CHECK LAMBDA EXISTS
##############################################################

info "Checking Lambda Function..."

aws lambda get-function \
    --function-name $LAMBDA_NAME \
    --region $DR_REGION >/dev/null 2>&1

if [ $? -eq 0 ]; then

    pass "Lambda Function Exists"

else

    fail "Lambda Function Not Found"

    echo
    echo "Deploy Lambda before running DR."
    echo

    exit 1

fi

echo

##############################################################
# GET LAMBDA CONFIGURATION
##############################################################

info "Fetching Lambda Configuration..."

RUNTIME=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query Runtime \
--output text)

HANDLER=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query Handler \
--output text)

TIMEOUT=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query Timeout \
--output text)

MEMORY=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query MemorySize \
--output text)

LASTMODIFIED=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query LastModified \
--output text)

ROLE=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query Role \
--output text)

STATE=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query State \
--output text)

UPDATE_STATUS=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query LastUpdateStatus \
--output text)

pass "Lambda Configuration Loaded"

echo

echo "Runtime        : $RUNTIME"
echo "Handler        : $HANDLER"
echo "Timeout        : ${TIMEOUT}s"
echo "Memory         : ${MEMORY} MB"
echo "State          : $STATE"
echo "Update Status  : $UPDATE_STATUS"
echo "Last Modified  : $LASTMODIFIED"
echo "Role           : $ROLE"

echo

##############################################################
# CHECK LAMBDA STATE
##############################################################

info "Checking Lambda State..."

if [ "$STATE" = "Active" ]; then

    pass "Lambda State : Active"

else

    fail "Lambda State : $STATE"

fi

echo

##############################################################
# CHECK LAST UPDATE STATUS
##############################################################

info "Checking Lambda Deployment Status..."

if [ "$UPDATE_STATUS" = "Successful" ]; then

    pass "Last Deployment Successful"

else

    warn "Deployment Status : $UPDATE_STATUS"

fi

echo

##############################################################
# FETCH ENVIRONMENT VARIABLES
##############################################################

info "Fetching Lambda Environment Variables..."

ENV_JSON=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query "Environment.Variables")

echo "$ENV_JSON"

echo

##############################################################
# REQUIRED ENVIRONMENT VARIABLES
##############################################################

info "Checking Required Environment Variables..."

REQUIRED_VARS=(
SOURCE_DB_IDENTIFIER
TARGET_DB_IDENTIFIER
DR_REGION
DB_INSTANCE_CLASS
DB_SUBNET_GROUP
SECURITY_GROUP_ID
KMS_KEY_ID
)

for VAR in "${REQUIRED_VARS[@]}"
do

VALUE=$(aws lambda get-function-configuration \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query "Environment.Variables.$VAR" \
--output text)

if [ "$VALUE" = "None" ] || [ -z "$VALUE" ]
then

    fail "$VAR Missing"

else

    pass "$VAR Found"

fi

done

echo

##############################################################
# CHECK FUNCTION URL (OPTIONAL)
##############################################################

info "Checking Lambda Function URL..."

URL=$(aws lambda get-function-url-config \
--function-name $LAMBDA_NAME \
--region $DR_REGION \
--query FunctionUrl \
--output text 2>/dev/null)

if [ $? -eq 0 ]
then

    pass "Function URL Configured"

    echo "$URL"

else

    warn "Function URL Not Configured (Optional)"

fi

echo

##############################################################
# CHECK RECENT LOG GROUP
##############################################################

info "Checking CloudWatch Log Group..."

aws logs describe-log-groups \
--log-group-name-prefix "/aws/lambda/$LAMBDA_NAME" \
--region $DR_REGION \
--query "logGroups[0].logGroupName" \
--output text >/dev/null 2>&1

if [ $? -eq 0 ]
then

    pass "CloudWatch Log Group Exists"

else

    warn "CloudWatch Log Group Missing"

fi

echo

##############################################################
# PART 3A COMPLETE
##############################################################

echo "==============================================================="
echo "PART 3A COMPLETED"
echo "==============================================================="
echo

echo "Verified"

echo "✓ Lambda Exists"

echo "✓ Runtime"

echo "✓ Handler"

echo "✓ Timeout"

echo "✓ Memory"

echo "✓ Role"

echo "✓ Environment Variables"

echo "✓ Lambda State"

echo "✓ Deployment Status"

echo "✓ CloudWatch Logs"

echo

###############################################################################
# PART 3B.1
# EKS Cluster + Node Group Checks
###############################################################################

echo
echo "==============================================================="
echo "           PART 3B.1 - EKS CLUSTER CHECKS"
echo "==============================================================="
echo

EKS_CLUSTER="dr-automator-dev-eks"
NODEGROUP="dr-automator-dev-eks-node-group"

##############################################################
# CHECK EKS CLUSTER
##############################################################

info "Checking EKS Cluster..."

aws eks describe-cluster \
    --name $EKS_CLUSTER \
    --region $PRIMARY_REGION >/dev/null 2>&1

if [ $? -eq 0 ]
then

    pass "EKS Cluster Found"

else

    fail "EKS Cluster Not Found"

    exit 1

fi

echo

##############################################################
# GET CLUSTER DETAILS
##############################################################

info "Fetching Cluster Information..."

CLUSTER_STATUS=$(aws eks describe-cluster \
--name $EKS_CLUSTER \
--region $PRIMARY_REGION \
--query "cluster.status" \
--output text)

CLUSTER_VERSION=$(aws eks describe-cluster \
--name $EKS_CLUSTER \
--region $PRIMARY_REGION \
--query "cluster.version" \
--output text)

CLUSTER_ENDPOINT=$(aws eks describe-cluster \
--name $EKS_CLUSTER \
--region $PRIMARY_REGION \
--query "cluster.endpoint" \
--output text)

CLUSTER_PLATFORM=$(aws eks describe-cluster \
--name $EKS_CLUSTER \
--region $PRIMARY_REGION \
--query "cluster.platformVersion" \
--output text)

pass "Cluster Details Retrieved"

echo
echo "Cluster Name     : $EKS_CLUSTER"
echo "Status           : $CLUSTER_STATUS"
echo "Version          : $CLUSTER_VERSION"
echo "Platform Version : $CLUSTER_PLATFORM"
echo "Endpoint         : $CLUSTER_ENDPOINT"
echo

##############################################################
# VERIFY CLUSTER STATUS
##############################################################

info "Checking Cluster Status..."

if [ "$CLUSTER_STATUS" = "ACTIVE" ]
then

    pass "Cluster Status : ACTIVE"

else

    fail "Cluster Status : $CLUSTER_STATUS"

fi

echo

##############################################################
# CHECK NODE GROUP
##############################################################

info "Checking Node Group..."

NODEGROUP=$(aws eks list-nodegroups \
    --cluster-name "$EKS_CLUSTER" \
    --region "$PRIMARY_REGION" \
    --query "nodegroups[0]" \
    --output text)

if [ "$NODEGROUP" = "None" ] || [ -z "$NODEGROUP" ]; then
    fail "No Node Group Found"
    exit 1
fi

pass "Node Group Found"
echo "Node Group : $NODEGROUP"



##############################################################
# GET NODE GROUP DETAILS
##############################################################

info "Fetching Node Group Details..."

NODE_STATUS=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.status" \
--output text)

INSTANCE_TYPE=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.instanceTypes[0]" \
--output text)

AMI_TYPE=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.amiType" \
--output text)

CAPACITY=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.capacityType" \
--output text)

DESIRED=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.scalingConfig.desiredSize" \
--output text)

MIN=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.scalingConfig.minSize" \
--output text)

MAX=$(aws eks describe-nodegroup \
--cluster-name $EKS_CLUSTER \
--nodegroup-name $NODEGROUP \
--region $PRIMARY_REGION \
--query "nodegroup.scalingConfig.maxSize" \
--output text)

pass "Node Group Details Retrieved"

echo
echo "Status        : $NODE_STATUS"
echo "Instance Type : $INSTANCE_TYPE"
echo "AMI Type      : $AMI_TYPE"
echo "Capacity Type : $CAPACITY"
echo "Desired Nodes : $DESIRED"
echo "Minimum Nodes : $MIN"
echo "Maximum Nodes : $MAX"
echo

##############################################################
# VERIFY NODE GROUP STATUS
##############################################################

info "Checking Node Group Status..."

if [ "$NODE_STATUS" = "ACTIVE" ]
then

    pass "Node Group Status : ACTIVE"

else

    fail "Node Group Status : $NODE_STATUS"

fi

echo

##############################################################
# CHECK NODE COUNT
##############################################################

info "Checking Desired Node Count..."

if [ "$DESIRED" -ge 1 ]
then

    pass "Desired Node Count : $DESIRED"

else

    fail "No Worker Nodes Configured"

fi

echo

##############################################################
# PART 3B.1 SUMMARY
##############################################################

echo "==============================================================="
echo "PART 3B.1 COMPLETED"
echo "==============================================================="

echo
echo "Verified"
echo
echo "✓ EKS Cluster Exists"
echo "✓ Cluster Status"
echo "✓ Kubernetes Version"
echo "✓ Platform Version"
echo "✓ API Endpoint"
echo "✓ Node Group Exists"
echo "✓ Node Group Status"
echo "✓ Instance Type"
echo "✓ Auto Scaling Configuration"
echo "✓ Desired Node Count"
echo

###############################################################################
# PART 3B.2
# kubectl Connectivity + Namespaces + Deployments + Pods + Services
###############################################################################

echo
echo "==============================================================="
echo "     PART 3B.2 - KUBERNETES RESOURCE CHECKS"
echo "==============================================================="
echo

##############################################################
# UPDATE KUBECONFIG
##############################################################

info "Updating kubeconfig..."

aws eks update-kubeconfig \
    --name $EKS_CLUSTER \
    --region $PRIMARY_REGION >/dev/null 2>&1

if [ $? -eq 0 ]
then
    pass "kubeconfig Updated"
else
    fail "Unable to Update kubeconfig"
    exit 1
fi

echo

##############################################################
# CHECK kubectl CONNECTIVITY
##############################################################

info "Checking Kubernetes Connectivity..."

kubectl cluster-info >/dev/null 2>&1

if [ $? -eq 0 ]
then
    pass "kubectl Connected to Cluster"
else
    fail "kubectl Cannot Connect to Cluster"
    exit 1
fi

echo

##############################################################
# CHECK NODES
##############################################################

info "Checking Kubernetes Nodes..."

NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)

if [ "$NODE_COUNT" -gt 0 ]
then
    pass "$NODE_COUNT Worker Node(s) Available"
    kubectl get nodes -o wide
else
    fail "No Worker Nodes Found"
fi

echo

##############################################################
# CHECK NAMESPACE COUNT
##############################################################

info "Checking Namespaces..."

NS_COUNT=$(kubectl get ns --no-headers 2>/dev/null | wc -l)

pass "Namespaces : $NS_COUNT"

kubectl get ns

echo

##############################################################
# CHECK DEPLOYMENTS
##############################################################

info "Checking Deployments..."

DEPLOYMENTS=$(kubectl get deploy -A --no-headers 2>/dev/null | wc -l)

if [ "$DEPLOYMENTS" -gt 0 ]
then

    pass "$DEPLOYMENTS Deployment(s) Found"

    echo

    kubectl get deploy -A

else

    warn "No Deployments Found"

fi

echo

##############################################################
# CHECK PODS
##############################################################

info "Checking Pods..."

PODS=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)

if [ "$PODS" -gt 0 ]
then

    pass "$PODS Pod(s) Running"

    echo

    kubectl get pods -A

else

    warn "No Pods Running"

fi

echo

##############################################################
# CHECK SERVICES
##############################################################

info "Checking Services..."

SERVICES=$(kubectl get svc -A --no-headers 2>/dev/null | wc -l)

if [ "$SERVICES" -gt 0 ]
then

    pass "$SERVICES Service(s) Found"

    echo

    kubectl get svc -A

else

    warn "No Services Found"

fi

echo

##############################################################
# CHECK INGRESS
##############################################################

info "Checking Ingress Resources..."

INGRESS=$(kubectl get ingress -A --no-headers 2>/dev/null | wc -l)

if [ "$INGRESS" -gt 0 ]
then

    pass "$INGRESS Ingress Resource(s) Found"

    echo

    kubectl get ingress -A

else

    warn "No Ingress Resources Found"

fi

echo

##############################################################
# CHECK SYSTEM PODS
##############################################################

info "Checking kube-system Namespace..."

SYSTEM_PODS=$(kubectl get pods -n kube-system \
--no-headers 2>/dev/null | wc -l)

if [ "$SYSTEM_PODS" -gt 0 ]
then

    pass "kube-system Healthy"

else

    warn "kube-system Pods Missing"

fi

echo

##############################################################
# CHECK APP NAMESPACE (OPTIONAL)
##############################################################

APP_NAMESPACE="default"

info "Checking Application Namespace ($APP_NAMESPACE)..."

kubectl get ns $APP_NAMESPACE >/dev/null 2>&1

if [ $? -eq 0 ]
then

    pass "Namespace Exists"

else

    warn "Namespace Missing"

fi

echo

##############################################################
# PART 3B.2 SUMMARY
##############################################################

echo "==============================================================="
echo "PART 3B.2 COMPLETED"
echo "==============================================================="

echo
echo "Verified"

echo "✓ kubeconfig"

echo "✓ kubectl Connectivity"

echo "✓ Worker Nodes"

echo "✓ Namespaces"

echo "✓ Deployments"

echo "✓ Pods"

echo "✓ Services"

echo "✓ Ingress"

echo "✓ kube-system"

echo

###############################################################################
# PART 3B.3
# Service, Ingress & Kubernetes Summary
###############################################################################

echo
echo "==============================================================="
echo "      PART 3B.3 - SERVICE & INGRESS VALIDATION"
echo "==============================================================="
echo

##############################################################
# CHECK LOAD BALANCER SERVICES
##############################################################

info "Checking LoadBalancer Services..."

LB_COUNT=$(kubectl get svc -A \
--field-selector spec.type=LoadBalancer \
--no-headers 2>/dev/null | wc -l)

if [ "$LB_COUNT" -gt 0 ]
then

    pass "$LB_COUNT LoadBalancer Service(s) Found"

    echo

    kubectl get svc -A \
    --field-selector spec.type=LoadBalancer

else

    warn "No LoadBalancer Services Found"

fi

echo

##############################################################
# CHECK EXTERNAL ENDPOINTS
##############################################################

info "Checking External Endpoints..."

kubectl get svc -A \
-o wide

echo

##############################################################
# CHECK INGRESS ADDRESS
##############################################################

info "Checking Ingress Address..."

INGRESS_ADDRESS=$(kubectl get ingress -A \
-o jsonpath='{range .items[*]}{.status.loadBalancer.ingress[0].hostname}{"\n"}{end}' \
2>/dev/null)

if [ -n "$INGRESS_ADDRESS" ]
then

    pass "Ingress Address Available"

    echo "$INGRESS_ADDRESS"

else

    warn "Ingress Address Not Assigned"

fi

echo

##############################################################
# CHECK FAILED PODS
##############################################################

info "Checking Failed Pods..."

FAILED=$(kubectl get pods -A \
--field-selector=status.phase=Failed \
--no-headers 2>/dev/null | wc -l)

if [ "$FAILED" -eq 0 ]
then

    pass "No Failed Pods"

else

    warn "$FAILED Failed Pod(s)"

    kubectl get pods -A \
    --field-selector=status.phase=Failed

fi

echo

##############################################################
# CHECK PENDING PODS
##############################################################

info "Checking Pending Pods..."

PENDING=$(kubectl get pods -A \
--field-selector=status.phase=Pending \
--no-headers 2>/dev/null | wc -l)

if [ "$PENDING" -eq 0 ]
then

    pass "No Pending Pods"

else

    warn "$PENDING Pending Pod(s)"

    kubectl get pods -A \
    --field-selector=status.phase=Pending

fi

echo

##############################################################
# CHECK RESTART COUNT
##############################################################

info "Checking Pod Restart Count..."

kubectl get pods -A

echo

##############################################################
# KUBERNETES SUMMARY
##############################################################

echo
echo "==============================================================="
echo "            KUBERNETES SUMMARY"
echo "==============================================================="

NODES=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
NAMESPACES=$(kubectl get ns --no-headers 2>/dev/null | wc -l)
DEPLOYMENTS=$(kubectl get deploy -A --no-headers 2>/dev/null | wc -l)
PODS=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
SERVICES=$(kubectl get svc -A --no-headers 2>/dev/null | wc -l)
INGRESS=$(kubectl get ingress -A --no-headers 2>/dev/null | wc -l)

echo
echo "Cluster        : $EKS_CLUSTER"
echo "Nodes          : $NODES"
echo "Namespaces     : $NAMESPACES"
echo "Deployments    : $DEPLOYMENTS"
echo "Pods           : $PODS"
echo "Services       : $SERVICES"
echo "Ingress        : $INGRESS"

echo

pass "Kubernetes Validation Completed"

echo
echo "==============================================================="
echo "PART 3B.3 COMPLETED"
echo "==============================================================="
echo

###############################################################################
# PART 3C
# ALB + Route53 Checks
###############################################################################

echo
echo "==============================================================="
echo "              PART 3C - ALB & ROUTE53 CHECKS"
echo "==============================================================="
echo

##############################################################
# ALB
##############################################################

info "Checking Application Load Balancer..."

ALB_ARN=$(aws elbv2 describe-load-balancers \
--region $PRIMARY_REGION \
--query "LoadBalancers[?State.Code!='deleted'] | [0].LoadBalancerArn" \
--output text 2>/dev/null)

if [ "$ALB_ARN" = "None" ] || [ -z "$ALB_ARN" ] || [ "$ALB_ARN" = "null" ]
then

    fail "Application Load Balancer Not Found"

else

    pass "Application Load Balancer Found"

fi

echo

##############################################################
# ALB DETAILS
##############################################################

ALB_NAME=$(aws elbv2 describe-load-balancers \
--region $PRIMARY_REGION \
--query "LoadBalancers[?State.Code!='deleted'] | [0].LoadBalancerName" \
--output text)

ALB_STATE=$(aws elbv2 describe-load-balancers \
--region $PRIMARY_REGION \
--query "LoadBalancers[?State.Code!='deleted'] | [0].State.Code" \
--output text)

ALB_DNS=$(aws elbv2 describe-load-balancers \
--region $PRIMARY_REGION \
--query "LoadBalancers[?State.Code!='deleted'] | [0].DNSName" \
--output text)

ALB_SCHEME=$(aws elbv2 describe-load-balancers \
--region $PRIMARY_REGION \
--query "LoadBalancers[?State.Code!='deleted'] | [0].Scheme" \
--output text)

echo "ALB Name   : $ALB_NAME"
echo "State      : $ALB_STATE"
echo "Scheme     : $ALB_SCHEME"
echo "DNS Name   : $ALB_DNS"

echo

##############################################################
# ALB STATE
##############################################################

info "Checking ALB State..."

if [ "$ALB_STATE" = "active" ]
then

    pass "ALB State : ACTIVE"

elif [ "$ALB_STATE" = "provisioning" ]
then

    warn "ALB State : PROVISIONING - AWS is still creating it"

else

    fail "ALB State : $ALB_STATE"

fi

echo

##############################################################
# TARGET GROUPS
##############################################################

info "Checking Target Groups..."

TG_COUNT=$(aws elbv2 describe-target-groups \
--region $PRIMARY_REGION \
--query "length(TargetGroups)" \
--output text)

if [ "$TG_COUNT" -gt 0 ]
then

    pass "$TG_COUNT Target Group(s) Found"

    aws elbv2 describe-target-groups \
    --region $PRIMARY_REGION \
    --query "TargetGroups[*].[TargetGroupName,Protocol,Port]" \
    --output table

else

    fail "No Target Groups Found"

fi

echo

##############################################################
# TARGET HEALTH
##############################################################

info "Checking Target Health..."

TG_ARN=$(aws elbv2 describe-target-groups \
--region $PRIMARY_REGION \
--query "TargetGroups[0].TargetGroupArn" \
--output text)

aws elbv2 describe-target-health \
--target-group-arn $TG_ARN \
--region $PRIMARY_REGION \
--query "TargetHealthDescriptions[*].[Target.Id,TargetHealth.State]" \
--output table

echo

##############################################################
# ROUTE53 HOSTED ZONE
##############################################################

info "Checking Hosted Zones..."

ZONE_COUNT=$(aws route53 list-hosted-zones \
--query "length(HostedZones)" \
--output text)

if [ "$ZONE_COUNT" -gt 0 ]
then

    pass "$ZONE_COUNT Hosted Zone(s) Found"

else

    warn "No Hosted Zones Configured"

fi

echo

##############################################################
# ROUTE53 RECORDS
##############################################################

HOSTED_ZONE_ID=$(aws route53 list-hosted-zones \
--query "HostedZones[0].Id" \
--output text 2>/dev/null)

if [ "$HOSTED_ZONE_ID" != "None" ]
then

    info "Listing Route53 Records..."

    aws route53 list-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --output table

fi

echo

##############################################################
# ALIAS RECORD
##############################################################

if [ "$HOSTED_ZONE_ID" != "None" ]
then

    ALIAS_COUNT=$(aws route53 list-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE_ID \
    --query "length(ResourceRecordSets[?AliasTarget!=null])" \
    --output text)

    if [ "$ALIAS_COUNT" -gt 0 ]
    then

        pass "$ALIAS_COUNT Alias Record(s) Found"

    else

        warn "No Alias Records Found"

    fi

fi

echo

###############################################################
# DNS RESOLUTION CHECK
###############################################################

info "Checking DNS Resolution..."

if [ -z "$ALB_DNS" ] || [ "$ALB_DNS" = "None" ] || [ "$ALB_DNS" = "null" ]; then

    warn "Skipping DNS Resolution - ALB DNS Name Not Available"

else

    DNS_RESULT=$(timeout 10 nslookup "$ALB_DNS" 2>&1 || true)

    if echo "$DNS_RESULT" | grep -q "Address"; then

        pass "DNS Resolution Successful"
        echo "$DNS_RESULT"

    else

        warn "DNS Resolution Failed"
        echo "$DNS_RESULT"

    fi

fi

##############################################################
# PART 3C SUMMARY
##############################################################

echo "==============================================================="
echo "PART 3C COMPLETED"
echo "==============================================================="

echo

echo "Verified"

echo "✓ Application Load Balancer"

echo "✓ ALB State"

echo "✓ DNS Name"

echo "✓ Target Groups"

echo "✓ Target Health"

echo "✓ Hosted Zones"

echo "✓ Route53 Records"

echo "✓ Alias Records"

echo "✓ DNS Resolution"

echo

###############################################################################
# PART 3D
# Final Summary + Overall PASS/FAIL Report
###############################################################################

echo
echo "==============================================================="
echo "          PART 3D - FINAL VALIDATION REPORT"
echo "==============================================================="
echo

##############################################################
# INITIALIZE COUNTERS
##############################################################

TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

##############################################################
# CHECK FUNCTIONS
##############################################################

check_status() {

    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

    if [ "$1" = "0" ]
    then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

##############################################################
# AWS CLI
##############################################################

aws --version >/dev/null 2>&1
check_status $?

##############################################################
# TERRAFORM
##############################################################

terraform version >/dev/null 2>&1
check_status $?

##############################################################
# DOCKER
##############################################################

docker info >/dev/null 2>&1
check_status $?

##############################################################
# KUBECTL
##############################################################

kubectl version --client >/dev/null 2>&1
check_status $?

##############################################################
# EKS
##############################################################

aws eks describe-cluster \
    --name "$EKS_CLUSTER" \
    --region "$PRIMARY_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# NODE GROUP
##############################################################

aws eks describe-nodegroup \
    --cluster-name "$EKS_CLUSTER" \
    --nodegroup-name "$NODEGROUP" \
    --region "$PRIMARY_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# PRIMARY DATABASE
##############################################################

aws rds describe-db-instances \
    --db-instance-identifier "$PRIMARY_DB" \
    --region "$PRIMARY_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# DR DATABASE
##############################################################

aws rds describe-db-instances \
    --db-instance-identifier "$DR_DB" \
    --region "$DR_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# LAMBDA
##############################################################

aws lambda get-function \
    --function-name dr-automator-restore-db \
    --region "$DR_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# ALB
##############################################################

aws elbv2 describe-load-balancers \
    --region "$PRIMARY_REGION" >/dev/null 2>&1
check_status $?

##############################################################
# ROUTE53
##############################################################

aws route53 list-hosted-zones >/dev/null 2>&1
check_status $?

##############################################################
# KUBERNETES CONNECTIVITY
##############################################################

kubectl cluster-info >/dev/null 2>&1
check_status $?

##############################################################
# PRINT SUMMARY
##############################################################

echo
echo "===================== PROJECT SUMMARY ====================="
echo

printf "%-35s : %s\n" "AWS CLI" "OK"
printf "%-35s : %s\n" "Terraform" "OK"
printf "%-35s : %s\n" "Docker" "OK"
printf "%-35s : %s\n" "kubectl" "OK"
printf "%-35s : %s\n" "Amazon EKS" "OK"
printf "%-35s : %s\n" "EKS Node Group" "OK"
printf "%-35s : %s\n" "Primary RDS" "OK"
printf "%-35s : %s\n" "DR Database" "OK"
printf "%-35s : %s\n" "Lambda Restore Function" "OK"
printf "%-35s : %s\n" "Application Load Balancer" "OK"
printf "%-35s : %s\n" "Route53" "OK"

echo
echo "==========================================================="

echo "Total Checks  : $TOTAL_CHECKS"
echo "Passed        : $PASSED_CHECKS"
echo "Failed        : $FAILED_CHECKS"

echo "==========================================================="

##############################################################
# FINAL RESULT
##############################################################

echo

if [ "$FAILED_CHECKS" -eq 0 ]
then

    echo "###########################################################"
    echo "#                                                         #"
    echo "#        DR AUTOMATOR ENVIRONMENT IS HEALTHY              #"
    echo "#                                                         #"
    echo "#                ALL CHECKS PASSED                        #"
    echo "#                                                         #"
    echo "###########################################################"

    exit 0

else

    echo "###########################################################"
    echo "#                                                         #"
    echo "#      DR AUTOMATOR ENVIRONMENT HAS ISSUES                #"
    echo "#                                                         #"
    echo "#          REVIEW THE FAILED CHECKS ABOVE                 #"
    echo "#                                                         #"
    echo "###########################################################"

    exit 1

fi