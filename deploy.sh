#!/bin/bash
 
# deploy.sh
 
set -e  # Exit immediately if a command exits with a non-zero status.
 
# Define AWS variables
AWS_ACCOUNT_ID="314806948291"
AWS_REGION="us-east-2"
AWS_REPOSITORY="lambda"
 
echo "Pushing the Docker image to Amazon ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest
 
echo "Creating/Updating Lambda function..."
aws lambda create-function \
  --function-name randmalay \
  --package-type Image \
  --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest \
  --role arn:aws:iam::$AWS_ACCOUNT_ID:role/LambdaExecutionRole \
  --architectures x86_64 \
  --timeout 15 \
  --memory-size 128 \
  || aws lambda update-function-code \
  --function-name randmalay \
  --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest
