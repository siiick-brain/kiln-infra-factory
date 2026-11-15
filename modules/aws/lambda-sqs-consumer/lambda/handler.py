def lambda_handler(event, context):
    return {
        "batchItemFailures": [],
        "recordCount": len(event.get("Records", [])),
    }
