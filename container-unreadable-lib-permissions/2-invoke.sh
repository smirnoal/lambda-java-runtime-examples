#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${FUNCTION_NAME:-container-unreadable-lib-permissions-demo}"
PAYLOAD="${PAYLOAD:-{}}"

aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --payload "$PAYLOAD" \
  --cli-binary-format raw-in-base64-out \
  /dev/stderr >/dev/null

echo
