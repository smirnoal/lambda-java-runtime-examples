# Container Unreadable Library Permissions

This example deploys a Java Lambda function as a container image and intentionally makes one dependency JAR unreadable inside `/var/task/lib`.

The handler prints a recursive tree of `/var/task` with POSIX permissions, so you can compare container-image behavior with the ZIP/JAR example.

## What This Tests

The Docker image uses the AWS Lambda Java 17 base image:

```dockerfile
FROM public.ecr.aws/lambda/java:17
```

It copies the handler JAR and dependencies into `/var/task/lib`, then makes `gson-*.jar` unreadable:

```dockerfile
COPY build/libs/function.jar ${LAMBDA_TASK_ROOT}/lib/
COPY build/dependency/* ${LAMBDA_TASK_ROOT}/lib/
RUN chmod 000 ${LAMBDA_TASK_ROOT}/lib/gson-*.jar
```

The handler itself does not use Gson. Gson is included only as a dependency JAR whose permissions are intentionally wrong.

## Prerequisites

- AWS CLI configured for your account
- Docker
- Java 17 or a Gradle toolchain-capable JDK
- Gradle

## Run

```sh
./0-init.sh
./1-deploy.sh
./2-invoke.sh
```

Expected response shape:

```text
rwxr-xr-x /var/task
`-- rwxr-xr-x lib/
    |-- rw-r--r-- function.jar
    |-- rw-r--r-- aws-lambda-java-core-1.4.0.jar
    `-- --------- gson-2.14.0.jar
```

Invoke once immediately after deployment, then invoke again after some time and compare the permissions.

## Cleanup

```sh
./3-cleanup.sh
```

By default cleanup deletes only the function and keeps the shared demo role and ECR repository. To delete those too:

```sh
DELETE_ROLE=true DELETE_REPOSITORY=true ./3-cleanup.sh
```

## Configuration

All scripts can be configured with environment variables:

```text
FUNCTION_NAME        default: container-unreadable-lib-permissions-demo
ROLE_NAME            default: lambda-java-runtime-examples-demo-role
ECR_REPOSITORY_NAME  default: lambda-java-runtime-examples-container-permissions
IMAGE_TAG            default: latest
AWS_REGION           default: AWS_DEFAULT_REGION or aws configure get region
```
