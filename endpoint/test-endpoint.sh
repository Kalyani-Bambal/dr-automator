#!/bin/bash

set -e

REGION="ap-south-1"

ALB_NAME="k8s-drautoma-drautoma-c17333964c"

DNS=$(aws elbv2 describe-load-balancers \
    --region ${REGION} \
    --query "LoadBalancers[?LoadBalancerName=='${ALB_NAME}'].DNSName" \
    --output text)

echo "========================================"
echo "DR Application Endpoint Test"
echo "========================================"

echo ""
echo "Endpoint:"
echo "http://${DNS}"

echo ""
echo "Health Check:"

curl http://${DNS}/health

echo ""
echo ""
echo "Verification completed successfully."