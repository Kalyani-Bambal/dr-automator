#!/bin/bash

aws cloudwatch delete-alarms \
--alarm-names \
dr-automator-lambda-errors \
dr-automator-lambda-duration \
dr-automator-rds-cpu \
dr-automator-rds-storage \
dr-automator-rds-connections \
--region ap-south-1

echo "CloudWatch alarms deleted."