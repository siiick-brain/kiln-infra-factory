#!/usr/bin/env bash
# Reads a drift plan log and lists every changed attribute except two known Moto artifacts.
# Moto returns queue policy JSON with spaces after separators, so the AWS provider reports a
# whitespace-only change on redrive_policy and on the dependent queue policy after every apply.
# Moto also drops bucket tags sent in CreateBucket, so the plan re-adds them after every apply.
# Exit 0: no changed attribute outside those artifacts. Exit 2: real drift, attributes printed.
set -euo pipefail

usage() {
  echo "Usage: scripts/drift-classify.sh <plan-log>" >&2
  echo "Use only against emulator plans. Against real AWS every change counts as drift." >&2
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
if (($# != 1)) || [[ ! -f "$1" ]]; then
  usage
  exit 2
fi

# Track the resource each changed attribute belongs to. Ignore only:
#   redrive_policy on aws_sqs_queue when Terraform marks it "# whitespace changes"
#   policy on aws_sqs_queue_policy, which is recomputed from that queue
#   tags and tags_all on aws_s3_bucket when every entry is an addition. AWS provider 6.x sends
#   bucket tags in CreateBucket and Moto 5.2.5 drops them, so a fresh bucket reads back untagged.
# Any other attribute, including policy on buckets or IAM roles, counts as drift.
changed="$(sed 's/\x1b\[[0-9;]*m//g' "$1" | awk '
  /# [^ ]+ will be updated in-place/ {
    for (i = 1; i <= NF; i++) if ($i == "#") { address = $(i + 1); break }
    n = split(address, parts, ".")
    type = parts[n - 1]
    next
  }
  pending != "" {
    # Inside a bucket tags map. Only "+" lines are the Moto artifact. "~" or "-" is real drift.
    if ($0 ~ /terraform:[ \t]+[-~] /) real = 1
    if ($0 ~ /terraform:[ \t]+}[ \t]*$/) {
      if (real) print pending
      pending = ""
    }
    next
  }
  match($0, /terraform:[ \t]+~ [a-z_]+[ \t]+=/) {
    attr = substr($0, RSTART, RLENGTH)
    sub(/.*~ /, "", attr)
    sub(/[ \t]+=$/, "", attr)
    if (type == "aws_sqs_queue" && attr == "redrive_policy" && $0 ~ /# whitespace changes/) next
    if (type == "aws_s3_bucket" && (attr == "tags" || attr == "tags_all") && $0 ~ /=[ \t]*\{[ \t]*$/) {
      pending = attr
      real = 0
      next
    }
    if (type == "aws_sqs_queue_policy" && attr == "policy") next
    print attr
  }' | sort -u)"
if [[ -z "$changed" ]]; then
  echo "No drift outside the known Moto artifacts (policy JSON whitespace, bucket tags dropped on create)."
  exit 0
fi
echo "Drift in: $(tr '\n' ' ' <<<"$changed")"
exit 2
