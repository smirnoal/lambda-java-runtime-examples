#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${FUNCTION_NAME:-jar-as-zip-demo}"
RUNTIME="${RUNTIME:-java17}"
HANDLER="${HANDLER:-example.TaskRootTreeHandler::handleRequest}"
JAR_PATH="${JAR_PATH:-build/libs/function.jar}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ROLE_ARN="$("./0-init.sh")"

gradle jar

if aws lambda get-function --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$JAR_PATH" >/dev/null

  aws lambda wait function-updated --function-name "$FUNCTION_NAME"

  aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --handler "$HANDLER" \
    --role "$ROLE_ARN" >/dev/null
else
  # IAM role trust can take a few seconds to propagate.
  sleep 10

  aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime "$RUNTIME" \
    --handler "$HANDLER" \
    --role "$ROLE_ARN" \
    --zip-file "fileb://$JAR_PATH" >/dev/null
fi

echo "Deployed $FUNCTION_NAME"
