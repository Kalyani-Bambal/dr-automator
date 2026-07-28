#!/bin/bash

set -e

REGION="ap-south-1"

TOPIC_NAME="dr-automator-alerts"

EMAIL="kalyanibambal97@gmail.com"

echo "========================================="
echo "Creating SNS Topic"
echo "========================================="

TOPIC_ARN=$(aws sns create-topic \
    --name ${TOPIC_NAME} \
    --region ${REGION} \
    --query TopicArn \
    --output text)

echo ""
echo "Topic ARN:"
echo ${TOPIC_ARN}

echo ""
echo "Applying Topic Policy..."

aws sns set-topic-attributes \
    --topic-arn ${TOPIC_ARN} \
    --attribute-name Policy \
    --attribute-value file://topic-policy.json \
    --region ${REGION}

echo ""
echo "Creating Email Subscription..."

aws sns subscribe \
    --topic-arn ${TOPIC_ARN} \
    --protocol email \
    --notification-endpoint ${EMAIL} \
    --region ${REGION}

echo ""
echo "========================================="
echo "Subscription request sent."
echo "Please check your email and click"
echo "'Confirm Subscription'."
echo "========================================="