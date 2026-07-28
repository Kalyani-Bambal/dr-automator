#!/bin/bash

echo "Listing alarms..."

aws cloudwatch describe-alarms \
--region ap-south-1

echo ""
echo "Lambda metrics..."

aws cloudwatch list-metrics \
--namespace AWS/Lambda \
--region ap-southeast-1

echo ""
echo "RDS metrics..."

aws cloudwatch list-metrics \
--namespace AWS/RDS \
--region ap-south-1