# Use the official AWS Lambda Python runtime as a base image
FROM public.ecr.aws/lambda/python:3.9

# Copy the Lambda function code into the container
COPY lambda_function.py ./

# Set the command to run the Lambda function handler
CMD ["lambda_function.lambda_handler"]
