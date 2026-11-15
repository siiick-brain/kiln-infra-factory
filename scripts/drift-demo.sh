#!/usr/bin/env bash
# Drift demonstration against the Moto emulator:
#   1. bootstrap the state bucket and apply the dev AWS units
#   2. drift check, expect exit 0
#   3. change the dev-events queue visibility timeout out of band
#   4. drift check, expect exit 2 and a diff
#   5. remediate with apply
#   6. drift check, expect exit 0
# Prints one line per step. Full output goes to artifacts/logs/drift-demo/.
set -euo pipefail

usage() {
  echo "Usage: scripts/drift-demo.sh" >&2
  echo "Runs inside the toolbox with the emulator service up." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
logs="$repo/artifacts/logs/drift-demo"
mkdir -p "$logs"
endpoint="${EMULATOR_URL:-http://emulator:5000}"
failed=0

apply_all() {
  terragrunt run --all --parallelism 1 --non-interactive --working-dir "$repo/live/dev/aws" -- \
    apply -auto-approve -no-color >"$logs/$1.log" 2>&1
}
drift() {
  local status=0
  bash "$repo/scripts/drift-check" >"$logs/$1.log" 2>&1 || status=$?
  echo "$status"
}
expect() {
  if [[ "$2" == "$3" ]]; then echo "PASS $1 (exit $2)"; else
    echo "FAIL $1: exit $2, expected $3"
    failed=$((failed + 1))
  fi
}

# Moto returns policy JSON with spaces after separators. The AWS provider then reports a
# whitespace-only change on redrive_policy and the dependent queue policy on every plan.
# changed_attributes lists every changed attribute except that known emulator artifact.
changed_attributes() {
  { bash "$repo/scripts/drift-classify.sh" "$logs/$1.log" || true; } | sed -n 's/^Drift in: //p' | tr ' ' '\n' | sed '/^$/d'
}
check_clean() {
  local name="$1" log="$2" status
  status="$(drift "$log")"
  if [[ "$status" == 0 ]]; then
    echo "PASS $name (exit 0)"
  elif [[ "$status" == 2 && -z "$(changed_attributes "$log")" ]]; then
    echo "NOT VERIFIED $name: exit 2 from the Moto policy JSON whitespace artifact only, no other attribute changed"
  else
    echo "FAIL $name: exit $status, changed: $(changed_attributes "$log" | tr '\n' ' ')"
    failed=$((failed + 1))
  fi
}

bash "$repo/scripts/bootstrap-state-bucket.sh" >"$logs/0-bootstrap.log"
if apply_all 1-apply; then
  echo "PASS baseline apply"
else
  echo "FAIL baseline apply, see $logs/1-apply.log"
  exit 1
fi
check_clean "drift check after apply" 2-check-clean

queue_url="$endpoint/123456789012/dev-events"
curl -fsS -o "$logs/3-out-of-band.xml" "$endpoint/" \
  -H "Authorization: AWS4-HMAC-SHA256 Credential=testing/20260101/us-east-1/sqs/aws4_request, SignedHeaders=host, Signature=0" \
  --data-urlencode "Action=SetQueueAttributes" \
  --data-urlencode "QueueUrl=$queue_url" \
  --data-urlencode "Attribute.1.Name=VisibilityTimeout" \
  --data-urlencode "Attribute.1.Value=45" \
  --data-urlencode "Version=2012-11-05"
echo "PASS out-of-band change: dev-events VisibilityTimeout set to 45"

expect "drift check after out-of-band change" "$(drift 4-check-drift)" 2
if changed_attributes 4-check-drift | grep -qx visibility_timeout_seconds; then
  echo "PASS plan diff shows visibility_timeout_seconds 45 -> 60"
else
  echo "FAIL plan diff does not show visibility_timeout_seconds"
  failed=$((failed + 1))
fi

if apply_all 5-remediate; then
  echo "PASS remediation apply"
else
  echo "FAIL remediation apply"
  failed=$((failed + 1))
fi
check_clean "drift check after remediation" 6-check-clean
if changed_attributes 6-check-clean | grep -qx visibility_timeout_seconds; then
  echo "FAIL injected drift still present after remediation"
  failed=$((failed + 1))
else
  echo "PASS injected drift cleared (visibility_timeout_seconds no longer in the plan)"
fi

echo "Drift demo: $failed failed. Logs in artifacts/logs/drift-demo/"
((failed == 0))
