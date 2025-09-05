import os, json, boto3, uuid
s3 = boto3.client("s3")
CURATED = os.environ["CURATED_BUCKET"]

def lambda_handler(event, context):
    key = f"curated/{uuid.uuid4()}.json"
    s3.put_object(Bucket=CURATED, Key=key, Body=json.dumps(event).encode("utf-8"))
    return {"status": "uploaded", "s3_key": key}
