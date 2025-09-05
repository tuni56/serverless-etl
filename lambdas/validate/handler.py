import json, os, hashlib, boto3

s3 = boto3.client("s3")
RAW = os.environ.get("RAW_BUCKET", "")

def _idem(key: str) -> bool:
    h = hashlib.sha256(key.encode()).hexdigest()
    flag_key = f"idem/{h}.flag"
    try:
        s3.head_object(Bucket=RAW, Key=flag_key)
        return True
    except s3.exceptions.NoSuchKey:
        s3.put_object(Bucket=RAW, Key=flag_key, Body=b"1")
        return False
    except Exception:
        return False

def lambda_handler(event, context):
    # validate schema and basic fields
    record_id = event.get("id", "")
    if not record_id:
        raise ValueError("missing id")
    if _idem(record_id):
        return {"status": "duplicate", "id": record_id}
    return {"status": "ok", "id": record_id, "payload": event.get("payload", {})}
