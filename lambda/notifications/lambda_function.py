import os
import json
import logging
import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
WEBHOOK_TOKEN = os.environ.get("WEBHOOK_TOKEN")

def build_subject(alerts):
    # Build a short subject from alerts
    if not alerts:
        return "Alertmanager notification"
    a = alerts[0]
    return a.get("annotations", {}).get("summary") or a.get("labels", {}).get("alertname") or "Alertmanager notification"

def build_message(alerts):
    lines = []
    for a in alerts:
        lines.append("Alert: {}".format(a.get("labels", {}).get("alertname", "unknown")))
        for k, v in (a.get("annotations") or {}).items():
            lines.append(f"{k}: {v}")
        lines.append("")
    return "\n".join(lines) or json.dumps(alerts)

def lambda_handler(event, context):
    """Accepts Alertmanager webhook payload and publishes to SNS topic specified by SNS_TOPIC_ARN env var.

    Expects payload structure described at https://prometheus.io/docs/alerting/latest/alertmanager/#webhook
    """
    logger.info("Received event: %s", json.dumps(event))

    # Verify shared secret header when invoked via Function URL / API GW
    headers = {}
    if isinstance(event, dict):
        headers = {k.lower(): v for k, v in (event.get("headers") or {}).items()}
    token_header = headers.get("x-webhook-token")
    # also accept token via query string param 'token'
    token_qs = None
    if isinstance(event, dict):
        qs = event.get('queryStringParameters')
        if qs and isinstance(qs, dict):
            token_qs = qs.get('token')
        # HTTP API v2 may put rawQueryString
        if not token_qs:
            raw = event.get('rawQueryString')
            if raw:
                try:
                    from urllib.parse import parse_qs
                    p = parse_qs(raw)
                    vals = p.get('token')
                    if vals:
                        token_qs = vals[0]
                except Exception:
                    pass

    provided_token = token_header or token_qs
    if WEBHOOK_TOKEN:
        if not provided_token or provided_token != WEBHOOK_TOKEN:
            logger.warning("Invalid or missing webhook token")
            return {"statusCode": 401, "body": "Unauthorized"}

    # Alertmanager sends a JSON body; when behind API Gateway, the body may be string-encoded
    body = event.get("body") if isinstance(event, dict) else None
    if body:
        try:
            payload = json.loads(body)
        except Exception:
            payload = body
    else:
        payload = event

    alerts = []
    if isinstance(payload, dict) and "alerts" in payload:
        alerts = payload["alerts"]
    elif isinstance(payload, list):
        alerts = payload

    subject = build_subject(alerts)
    message = build_message(alerts)

    if not SNS_TOPIC_ARN:
        logger.error("SNS_TOPIC_ARN not set in environment; dropping notification")
        return {"statusCode": 500, "body": "SNS_TOPIC_ARN not configured"}

    sns = boto3.client("sns")
    try:
        resp = sns.publish(TopicArn=SNS_TOPIC_ARN, Subject=subject[:100], Message=message)
        logger.info("Published to SNS: %s", resp.get("MessageId"))
        return {"statusCode": 200, "body": "ok"}
    except Exception as e:
        logger.exception("Failed to publish to SNS")
        return {"statusCode": 500, "body": str(e)}


# For local testing
if __name__ == "__main__":
    sample = {"alerts": [{"labels": {"alertname": "TestAlert"}, "annotations": {"summary": "Test alert"}}]}
    print(lambda_handler(sample, None))
