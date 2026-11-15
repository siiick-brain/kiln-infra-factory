"""Summarise a Checkov JSON report: passed, failed and accepted (skipped) counts, then failures by check.

Checkov writes one JSON document per scanned directory. This reads all of them.
Usage: python scripts/checkov-summary.py <checkov.json> [path/to/.checkov.yaml]
"""

import collections
import json
import re
import sys


def documents(text):
    decoder = json.JSONDecoder()
    index = 0
    while index < len(text):
        rest = text[index:].lstrip()
        if not rest:
            break
        obj, used = decoder.raw_decode(rest)
        index = len(text) - len(rest) + used
        yield from (obj if isinstance(obj, list) else [obj])


def main(argv):
    if len(argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    passed = failed = 0
    failures = collections.Counter()
    with open(argv[1], encoding="utf-8") as handle:
        for doc in documents(handle.read()):
            summary = doc.get("summary", {})
            passed += summary.get("passed", 0)
            failed += summary.get("failed", 0)
            for check in doc.get("results", {}).get("failed_checks", []):
                failures[check["check_id"]] += 1
    accepted = 0
    if len(argv) > 2:
        with open(argv[2], encoding="utf-8") as handle:
            accepted = len(re.findall(r"^\s*-\s*CKV", handle.read(), flags=re.MULTILINE))
    print(f"passed {passed} failed {failed} accepted-skips {accepted}")
    for check_id, count in failures.most_common():
        print(f"FAIL {check_id} x{count}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
