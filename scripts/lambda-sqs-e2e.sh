#!/usr/bin/env bash
# Sends one message to the dev consumer queue on the Moto emulator and checks that the Lambda
# function ran. Moto invokes the function through the queue's event source mapping and writes
# the function output to CloudWatch Logs. Needs the emulator started with compose.lambda.yml and
# the dev AWS units applied. It never contacts a real AWS endpoint.
set -euo pipefail

usage() {
  echo "Usage: scripts/lambda-sqs-e2e.sh [endpoint]" >&2
  echo "Default endpoint: http://emulator:5000. Start the emulator with compose.lambda.yml first." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# > 1)); then
  usage
  exit 2
fi

endpoint="${1:-${EMULATOR_URL:-http://emulator:5000}}"
case "$endpoint" in
  http://*@*) echo "Refusing an endpoint with user info: $endpoint" >&2; exit 2 ;;
  http://emulator:* | http://127.0.0.1:* | http://localhost:*) ;;
  *)
    echo "Refusing non-local endpoint: $endpoint" >&2
    exit 2
    ;;
esac

queue="dev-consumer-queue"
log_group="/aws/lambda/dev-consumer"
timeout_seconds=180

# Moto does not check signatures. The credential scope only tells it which service is called.
auth() {
  echo "Authorization: AWS4-HMAC-SHA256 Credential=testing/20260101/us-east-1/$1/aws4_request, SignedHeaders=host, Signature=0"
}

queue_url="$(curl -fsS -X POST "$endpoint/" -H "$(auth sqs)" \
  --data-urlencode "Action=GetQueueUrl" --data-urlencode "QueueName=$queue" |
  sed -n 's:.*<QueueUrl>\(.*\)</QueueUrl>.*:\1:p')"
if [[ -z "$queue_url" ]]; then
  echo "FAIL queue $queue not found. Apply the dev AWS units first." >&2
  exit 1
fi
echo "PASS queue found: $queue"

marker="kiln-e2e-$(date +%s)-$$"
curl -fsS -X POST "$endpoint/" -H "$(auth sqs)" \
  --data-urlencode "Action=SendMessage" --data-urlencode "QueueUrl=$queue_url" \
  --data-urlencode "MessageBody={\"marker\":\"$marker\"}" >/dev/null
echo "PASS message sent: $marker"

deadline=$((SECONDS + timeout_seconds))
while ((SECONDS < deadline)); do
  events="$(curl -fsS -X POST "$endpoint/" -H "$(auth logs)" \
    -H "Content-Type: application/x-amz-json-1.1" \
    -H "X-Amz-Target: Logs_20140328.FilterLogEvents" \
    -d "{\"logGroupName\":\"$log_group\"}" 2>/dev/null || true)"
  if grep -q '"recordCount": *1' <<<"$events" || grep -q 'recordCount\\": *1' <<<"$events"; then
    echo "PASS message reached the function (log group $log_group shows recordCount 1)"
    exit 0
  fi
  sleep 5
done
echo "FAIL no invocation in $log_group after ${timeout_seconds}s" >&2
exit 1
