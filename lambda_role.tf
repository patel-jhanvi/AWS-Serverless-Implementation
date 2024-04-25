import json

import boto3

s3_client = boto3.client('s3')

rekognition_client = boto3.client('rekognition')

def lambda_handler(event, context):

for record in event['Records']:

# Extract bucket name and key from the S3 event

bucket_name = record['s3']['bucket']['name']

key = record['s3']['object']['key']

# Read the image from S3 bucket

response = s3_client.get_object(Bucket=bucket_name, Key=key)

image = response['Body'].read()

# Call Amazon Rekognition's detect_labels API to get labels for the image

response = rekognition_client.detect_labels(Image={'Bytes': image}, MaxLabels=10, MinConfidence=90)

# Get the labels and confidence scores from the API response

labels = []

for label in response['Labels']:

labels.append(label['Name'])

# Determine the overall analysis result based on the presence of the Label of interest (e.g. Dog) and minimum confidence score

label_of_interest = 'Dog'

min_confidence = 90

analysis_result = 'SUCCESS' if label_of_interest in labels and response['Labels'][labels.index(label_of_interest)]['Confidence'] >= min_confidence else 'FAILURE'

# Move the original image to /analyzed/success or /analyzed/failure folder based on analysis result

if analysis_result == 'SUCCESS':

target_key = key.replace('images', 'analyzed/success')

else:

target_key = key.replace('images', 'analyzed/failure')

s3_client.copy_object(Bucket=bucket_name, CopySource={'Bucket': bucket_name, 'Key': key}, Key=target_key)

s3_client.delete_object(Bucket=bucket_name, Key=key)

# Send notification to Quality Control group with analysis results

sns_client = boto3.client('sns')

topic_arn = 'arn:aws:sns:us-east-1:123456789012:ImageAnalysisResults'

message = f"Image analysis result for {key}: {analysis_result}\nLabels: {labels}"

sns_client.publish(TopicArn=topic_arn, Message=message)

return {

'statusCode': 200,

'body': json.dumps('Image analysis complete')

} 