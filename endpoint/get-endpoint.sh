#!/bin/bash

set -e

REGION="ap-south-1"

ALB_NAME="k8s-drautoma-drautoma-c17333964c"

echo "Retrieving ALB endpoint..."

DNS=$(aws elbv2 describe-load-balancers \
    --region ${REGION} \
    --query "LoadBalancers[?LoadBalancerName=='${ALB_NAME}'].DNSName" \
    --output text)

echo ""
echo "Application Endpoint:"
echo "http://${DNS}"