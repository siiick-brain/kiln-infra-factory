#!/usr/bin/env bash
# Creates the versioned Terraform state bucket on the Moto emulator. The emulator keeps data in memory,
# so run this after every emulator restart. It never contacts a real AWS endpoint.
set -euo pipefail

usage() {
  echo "Usage: scripts/bootstrap-state-bucket.sh [bucket] [endpoint]" >&2
  echo "Defaults: kiln-infra-state http://emulator:5000" >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

bucket="${1:-kiln-infra-state}"
endpoint="${2:-${EMULATOR_URL:-http://emulator:5000}}"
case "$endpoint" in
  http://*@*) echo "Refusing an endpoint with user info: $endpoint" >&2; exit 2 ;;
  http://emulator:* | http://127.0.0.1:* | http://localhost:*) ;;
  *)
    echo "Refusing non-local endpoint: $endpoint" >&2
    exit 2
    ;;
esac

# Wait up to 30 seconds for the emulator after a restart.
for _ in $(seq 1 30); do
  curl -fsS -o /dev/null "$endpoint/moto-api/" && break
  sleep 1
done

# Moto routes requests by the service named in the signature scope. The key is the fake value "testing".
auth="Authorization: AWS4-HMAC-SHA256 Credential=testing/20260101/us-east-1/s3/aws4_request, SignedHeaders=host, Signature=0"
# Create unconditionally. 200 means created, 409 means it already exists and is owned by this account.
code="$(curl -sS -o /dev/null -w '%{http_code}' -H "$auth" -X PUT "$endpoint/$bucket")"
case "$code" in
  200) echo "CREATED $bucket" ;;
  409) echo "EXISTS $bucket" ;;
  *)
    echo "Bucket create returned HTTP $code" >&2
    exit 1
    ;;
esac
curl -fsS -o /dev/null -H "$auth" -H "Content-Type: application/xml" -X PUT "$endpoint/$bucket?versioning" \
  -d '<VersioningConfiguration xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Status>Enabled</Status></VersioningConfiguration>'
echo "VERSIONING enabled on $bucket"
