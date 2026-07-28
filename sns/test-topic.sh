#!/bin/bash

set -e

REGION="ap-south-1"

TOPIC_ARN=$(aws sns list-topics \
    --region ${REGION} \
    --query "Topics[?contains(TopicArn,'dr-automator-alerts')].TopicArn" \
    --output text)

echo "Publishing Test Notification..."

aws sns publish \
    --topic-arn ${TOPIC_ARN} \
    --subject "DR Automator Test Notification" \
    --message "This is a test notification from the DR Automator SNS topic." \
    --region ${REGION}

echo "Test notification published."