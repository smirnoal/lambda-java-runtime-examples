#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${FUNCTION_NAME:-container-unreadable-lib-permissions-demo}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
AWS_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region)}}"

if [[ -z "$AWS_REGION" ]]; then
  echo "AWS region is not set. Configure AWS_REGION, AWS_DEFAULT_REGION, or aws configure get region." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

INIT_OUTPUT="$("./0-init.sh")"
ROLE_ARN="$(printf '%s\n' "$INIT_OUTPUT" | sed -n 's/^ROLE_ARN=//p')"
REPOSITORY_URI="$(printf '%s\n' "$INIT_OUTPUT" | sed -n 's/^REPOSITORY_URI=//p')"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
IMAGE_URI="$REPOSITORY_URI:$IMAGE_TAG"

gradle prepareImage

aws ecr get-login-password --region "$AWS_REGION" \
  | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

docker build --platform linux/amd64 -t "$IMAGE_URI" .
docker push "$IMAGE_URI"

if aws lambda get-function --function-name "$FUNCTION_NAME" >/dev/null 2>&1; then
  aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --image-uri "$IMAGE_URI" >/dev/null

  aws lambda wait function-updated --function-name "$FUNCTION_NAME"
  aws lambda wait function-active --function-name "$FUNCTION_NAME"
else
  # IAM role trust and ECR image availability can take a few seconds to propagate.
  sleep 10

  aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --package-type Image \
    --code "ImageUri=$IMAGE_URI" \
    --role "$ROLE_ARN" >/dev/null

  aws lambda wait function-active --function-name "$FUNCTION_NAME"
fi

echo "Deployed $FUNCTION_NAME from $IMAGE_URI"
