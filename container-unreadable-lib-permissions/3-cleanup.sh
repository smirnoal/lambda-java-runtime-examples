#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${FUNCTION_NAME:-container-unreadable-lib-permissions-demo}"
ROLE_NAME="${ROLE_NAME:-lambda-java-runtime-examples-demo-role}"
ECR_REPOSITORY_NAME="${ECR_REPOSITORY_NAME:-lambda-java-runtime-examples-container-permissions}"
BASIC_EXECUTION_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
DELETE_ROLE="${DELETE_ROLE:-false}"
DELETE_REPOSITORY="${DELETE_REPOSITORY:-false}"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region)}}"

if [[ -z "$AWS_REGION" ]]; then
  echo "AWS region is not set. Configure AWS_REGION, AWS_DEFAULT_REGION, or aws configure get region." >&2
  exit 1
fi

if aws lambda get-function --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  aws lambda delete-function --function-name "$FUNCTION_NAME"
  echo "Deleted function $FUNCTION_NAME"
else
  echo "Function $FUNCTION_NAME does not exist"
fi

if [[ "$DELETE_REPOSITORY" == "true" ]]; then
  if aws ecr describe-repositories \
    --repository-names "$ECR_REPOSITORY_NAME" \
    --region "$AWS_REGION" >/dev/null 2>&1; then
    aws ecr delete-repository \
      --repository-name "$ECR_REPOSITORY_NAME" \
      --region "$AWS_REGION" \
      --force >/dev/null
    echo "Deleted ECR repository $ECR_REPOSITORY_NAME"
  else
    echo "ECR repository $ECR_REPOSITORY_NAME does not exist"
  fi
else
  echo "Kept ECR repository $ECR_REPOSITORY_NAME. Set DELETE_REPOSITORY=true to delete it."
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
