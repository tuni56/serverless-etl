from datetime import datetime

def lambda_handler(event, context):
    p = event.get("payload", {})
    if "timestamp" in p:
        p["timestamp"] = datetime.fromisoformat(p["timestamp"]).isoformat()
    return {**event, "payload": p}
