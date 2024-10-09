#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.

# Ensure essential environment variables are set
if [ -z "$AWS_ACCOUNT_ID" ] || [ -z "$AWS_REGION" ] || [ -z "$AWS_REPOSITORY" ]; then
  echo "Environment variables AWS_ACCOUNT_ID, AWS_REGION, and AWS_REPOSITORY must be set."
  exit 1
fi

echo "Pushing the Docker image to Amazon ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest || {
  echo "Docker push failed!"
  exit 1
}

echo "Creating/Updating Lambda function..."
aws lambda create-function \
  --function-name randmalay \
  --package-type Image \
  --code ImageUri=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest \
  --role arn:aws:iam::$AWS_ACCOUNT_ID:role/LambdaExecutionRole \
  --architectures x86_64 \
  --timeout 15 \
  --memory-size 128 || {
    echo "Function already exists, updating code..."
    aws lambda update-function-code \
      --function-name randmalay \
      --image-uri $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$AWS_REPOSITORY:latest || {
        echo "Failed to create or update Lambda function!"
        exit 1
      }
  }
