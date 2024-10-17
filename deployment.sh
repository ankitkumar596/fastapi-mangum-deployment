#!/bin/bash

# Variables (adjust as needed)
FUNCTION_NAME="fastapi-mangum"
S3_BUCKET="localstacktest"
BUILD_ID=$(date +"%Y%m%d-%H%M%S")
ZIP_FILE="fastapi-mangum-$BUILD_ID.zip"
REGION="us-east-1"

# Step 1: Clean up old 'package/' directory (if it exists)
echo "Cleaning up old package..."
rm -rf package/

# Step 2: Install dependencies into a new 'package/' directory
echo "Installing dependencies..."
mkdir -p package
pip install -r requirements.txt -t package/ --no-cache-dir

# Step 3: Copy application code to the 'package/' directory
echo "Copying application code..."
cp main.py package/

# Step 4: Create a new ZIP file from the 'package/' directory
echo "Creating ZIP file..."
cd package
zip -r ../$ZIP_FILE . -x "*/__pycache__/*" "*.pyc" ".DS_Store"
cd ..

# Step 5: Upload the ZIP file to S3
echo "Uploading ZIP to S3..."
aws s3 cp $ZIP_FILE s3://$S3_BUCKET/

# Step 6: Update the Lambda function with the new code
echo "Updating Lambda function..."
aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --s3-bucket $S3_BUCKET \
    --s3-key $ZIP_FILE \
    --region $REGION

echo "Deployment completed successfully!"
