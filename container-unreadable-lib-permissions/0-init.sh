#!/usr/bin/env bash
set -euo pipefail

ROLE_NAME="${ROLE_NAME:-lambda-java-runtime-examples-demo-role}"
ECR_REPOSITORY_NAME="${ECR_REPOSITORY_NAME:-lambda-java-runtime-examples-container-permissions}"
BASIC_EXECUTION_POLICY_ARN="arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region)}}"

if [[ -z "$AWS_REGION" ]]; then
  echo "AWS region is not set. Configure AWS_REGION, AWS_DEFAULT_REGION, or aws configure get region." >&2
  exit 1
fi

if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' >/dev/null

  aws iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$BASIC_EXECUTION_POLICY_ARN"
fi

if ! aws ecr describe-repositories \
  --repository-names "$ECR_REPOSITORY_NAME" \
  --region "$AWS_REGION" >/dev/null 2>&1; then
  aws ecr create-repository \
    --repository-name "$ECR_REPOSITORY_NAME" \
    --region "$AWS_REGION" >/dev/null
fi

aws iam wait role-exists --role-name "$ROLE_NAME"

ROLE_ARN="$(aws iam get-role \
  --role-name "$ROLE_NAME" \
  --query 'Role.Arn' \
  --output text)"

REPOSITORY_URI="$(aws ecr describe-repositories \
  --repository-names "$ECR_REPOSITORY_NAME" \
  --region "$AWS_REGION" \
  --query 'repositories[0].repositoryUri' \
  --output text)"

printf 'ROLE_ARN=%s\n' "$ROLE_ARN"
printf 'REPOSITORY_URI=%s\n' "$REPOSITORY_URI"
