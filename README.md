# AWS-Serverless-Implementation


# Serverless Image Recognition Application Implementation

## Introduction

This repository documents the implementation of a serverless image recognition application for Company X. The application automates the inspection process by analyzing digital images of widgets using AWS cloud services. By leveraging services like S3, SQS, Lambda, SNS, and AWS Rekognition, this application streamlines quality control operations and enhances efficiency.

The Architecture:
![image](https://github.com/patel-jhanvi/AWS-Serverless-Implementation/assets/61945134/929bc4a5-123b-48c3-b510-ff8b210eac4c)


## Step-by-Step Implementation Guide

### Step 1: Create an S3 Bucket

Create an S3 bucket with a unique name to store the images and analyze them. Ensure to create `/images` and `/analyzed` folders within the bucket.

**Code Snippet:**
```bash
aws s3api create-bucket --bucket your-bucket-name --region your-region
```

### Step 2: Create an SQS Queue

Create a Simple Queue Service (SQS) queue to handle S3 bucket events. You can create the SQS queue from the AWS Management Console or using the AWS CLI.

**Code Snippet:**
```bash
aws sqs create-queue --queue-name your-queue-name
```

### Step 3: Configure the SQS Queue to Receive S3 Events

Configure the SQS queue to receive S3 events by creating an S3 bucket notification. Navigate to your S3 bucket > Properties > Events > Add Notification. Select the "All object create events" option and specify the SQS queue created in Step 2.

### Step 4: Create a Dead-Letter Queue

To handle problematic messages in the SQS queue, create a Dead-Letter Queue (DLQ) for the main SQS queue. This ensures efficient handling of messages that cannot be processed by the Lambda function.

### Step 5: Create a Lambda Function

Create a new Lambda function from the AWS Management Console. Configure the function to use the SQS queue created in Step 2 as the trigger. Set the appropriate IAM role for the function.

### Step 6: Write Lambda Function Code

Write the Lambda function code to read messages from the SQS queue, extract the S3 bucket location from the message, and invoke the Rekognition API. You can use the provided Python code snippet as a reference.

**Code Snippet:**
```python
import json
import boto3

s3_client = boto3.client('s3')
rekognition_client = boto3.client('rekognition')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        response = s3_client.get_object(Bucket=bucket_name, Key=key)
        image = response['Body'].read()
        response = rekognition_client.detect_labels(Image={'Bytes': image}, MaxLabels=10, MinConfidence=90)
        labels = [label['Name'] for label in response['Labels']]
        # Perform further processing based on analysis results
```

### Step 7: Configure Rekognition API

Configure the Rekognition API to analyze the images uploaded to the S3 bucket. Use the `detect_labels` function of AWS Rekognition to analyze the images and extract labels with confidence scores.

### Step 8: Configure Success/Failure Criteria

Define the criteria for determining if the image analysis is successful or not. Compare the detected labels with predefined labels of interest and set a minimum threshold of confidence.

### Step 9: Move the Analyzed Image

Move the original file uploaded to the S3 bucket's `/images` folder to the `/analyzed` folder based on the analysis result. Implement a S3 lifecycle rule to move the image file to AWS S3 Glacier for retention purposes if required.

### Step 10: Send Notifications

Utilize AWS SNS service to send notifications to the Quality Control group with the overall success/failure of the image analysis, detected labels, and respective confidence scores. Create a new SNS topic and subscribe the email addresses of the project members. Configure the Lambda function to send appropriate notifications to the subscribers.

## Conclusion

The implementation of the serverless image recognition application using AWS cloud services offers significant benefits to Company X. By automating the inspection process and leveraging scalable infrastructure, the application improves efficiency, accuracy, and cost-effectiveness.

