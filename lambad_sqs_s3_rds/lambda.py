import json
import boto3
import os
import pymysql
import uuid

# sns_client = boto3.client("sns")


def get_secret():

    secret_name = os.environ.get("SECRET_NAME")
    region_name = "ap-south-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(service_name="secretsmanager", region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
        return get_secret_value_response["SecretString"]
    except Exception as e:
        raise e


# def get_db_connection(secret):
#     return pymysql.connect(
#         host=secret["host"],
#         user=secret["username"],
#         password=secret["password"],
#         database=secret["dbname"],
#         connect_timeout=5,
#     )


def get_db_connection():
    return pymysql.connect(
        host="*******************************",
        user="admin",
        password="****************",
        database="mydatabase",
        connect_timeout=5,
    )


def lambda_handler(event, context):
    # topic_arn = os.environ.get("SNS_TOPIC_ARN")

    # if not topic_arn:
    #     raise Exception("SNS_TOPIC_ARN not set")
    secret = json.loads(get_secret())
    print(secret)
    # connection = get_db_connection(secret)
    connection = get_db_connection()
    # print(connection)
    cursor = connection.cursor()

    i = 1

    for sqs_record in event["Records"]:
        try:
            body = json.loads(sqs_record["body"])

            for s3_record in body["Records"]:
                objectName = s3_record["s3"]["object"]["key"]
                uploadedAt = s3_record["eventTime"]
                bucketName = s3_record["s3"]["bucket"]["name"]
                regionName = s3_record["awsRegion"]

                # extension = objectName.split(".")[-1]

                public_url = (
                    f"https://{bucketName}.s3.{regionName}.amazonaws.com/{objectName}"
                )
                random_uuid = uuid.uuid4()
                print(random_uuid)

                print("Processing:", objectName)

                # ✅ INSERT INTO RDS
                insert_query = """
                    INSERT INTO table1
                    (id, objectName, uploadedAt, public_url)
                    VALUES (%s, %s, %s, %s)
                """

                cursor.execute(
                    insert_query,
                    (random_uuid, objectName, uploadedAt, public_url),
                )

                connection.commit()

                print("Inserted into RDS")

                # dynamodb = boto3.resource("dynamodb")
                # table = dynamodb.Table("table1")

                # item = {
                #     "id": str(random_uuid),  # primary key
                #     "objectName": objectName,
                #     "bucketName": bucketName,
                #     "regionName": regionName,
                #     "timeCreated": timeCreated,
                #     "extension": extension,
                #     "objectUrl": object_public_url,
                # }

                # table.put_item(Item=item)

                # # ✅ SNS Message
                # message = {
                #     "event": "S3_OBJECT_CREATED",
                #     "fileName": objectName,
                #     "fileType": extension,
                #     "bucket": bucketName,
                #     "region": regionName,
                #     "createdAt": timeCreated,
                #     "fileUrl": object_public_url,
                # }

                # subject = f"New File Uploaded: {objectName}"

                # response = sns_client.publish(
                #     TopicArn=topic_arn, Message=json.dumps(message), Subject=subject
                # )

                # print("SNS MessageId:", response["MessageId"])
                # print("----------------------------------------")

            i += 1

        except Exception as e:
            print(f"Error processing record {i}: {str(e)}")
            i += 1

    # cursor.close()
    # connection.close()

    return {
        "statusCode": 200,
        "body": json.dumps("Processed all records successfully!"),
    }
