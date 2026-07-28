#!/bin/bash

set -e

REGION="ap-south-1"

TOPIC_ARN=$(aws sns list-topics \
    --region ${REGION} \
    --query "Topics[?contains(TopicArn,'dr-automator-alerts')].TopicArn" \
    --output text)

echo "Deleting Topic..."

aws sns delete-topic \
    --topic-arn ${TOPIC_ARN} \
    --region ${REGION}

echo "SNS Topic Deleted."