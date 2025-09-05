def lambda_handler(event, context):
    payload = event.get("payload", {})
    payload["enriched"] = True
    return {**event, "payload": payload}
