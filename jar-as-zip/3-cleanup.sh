#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${FUNCTION_NAME:-jar-as-zip-demo}"
ROLE_NAME="${ROLE_NAME:-lambda-java-runtime-examples-demo-role}"
BASIC_EXECUTION_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
DELETE_ROLE="${DELETE_ROLE:-false}"

if aws lambda get-function --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  aws lambda delete-function --function-name "$FUNCTION_NAME"
  echo "Deleted function $FUNCTION_NAME"
else
  echo "Function $FUNCTION_NAME does not exist"
fi

if [[ "$DELETE_ROLE" == "true" ]]; then
  if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    aws iam detach-role-policy \
      --role-name "$ROLE_NAME" \
      --policy-arn "$BASIC_EXECUTION_POLICY_ARN" || true

    aws iam delete-role --role-name "$ROLE_NAME"
    echo "Deleted role $ROLE_NAME"
  else
    echo "Role $ROLE_NAME does not exist"
  fi
else
  echo "Kept role $ROLE_NAME. Set DELETE_ROLE=true to delete it."
fi
