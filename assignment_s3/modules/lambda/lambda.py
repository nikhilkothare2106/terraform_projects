import json
import boto3
import os

sns = boto3.client("sns")

TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]


def lambda_handler(event, context):

    print(json.dumps(event))
    print("------------------------------------------")

    record = event["Records"][0]
    bucket = record["s3"]["bucket"]["name"]
    key = record["s3"]["object"]["key"]
    eventAction = record["eventName"]
    # print(f"New file uploaded: {key} in bucket {bucket}")
    print(f"{eventAction} action performed on {key} in bucket {bucket}")

    sns.publish(
        TopicArn=TOPIC_ARN,
        # Subject="New file Uploaded",
        # Message=f"New file {key} was uploaded in bucket {bucket}"
        Subject=f"{eventAction}",
        Message=f"{eventAction} action performed on {key} in bucket {bucket} ",
    )

    return {"statusCode": 200, "body": "Success"}
