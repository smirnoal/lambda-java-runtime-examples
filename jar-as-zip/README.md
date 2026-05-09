# JAR as ZIP

This example demonstrates that a Java `.jar` can be deployed to AWS Lambda through the normal `--zip-file` path.

The built artifact is a ZIP-shaped JAR:

```text
function.jar
├── example/TaskRootTreeHandler.class
└── lib/
    ├── aws-lambda-java-core-*.jar
    └── gson-*.jar
```

Lambda treats this file as the deployment archive. It is not launched as an executable JVM JAR; the managed Java runtime loads the handler using the configured handler string.

## Prerequisites

- AWS CLI configured for your account
- Java 17 or a Gradle toolchain-capable JDK
- Gradle

## Run

```sh
./0-init.sh
./1-deploy.sh
./2-invoke.sh
```

Expected response:

```text
/var/task
|-- example/
|   `-- TaskRootTreeHandler.class
`-- lib/
    |-- aws-lambda-java-core-1.4.0.jar
    `-- gson-2.14.0.jar
```

## Cleanup

```sh
./3-cleanup.sh
```

By default cleanup deletes only the function and keeps the shared demo role for future examples. To delete the role too:

```sh
DELETE_ROLE=true ./3-cleanup.sh
```

## Configuration

All scripts can be configured with environment variables:

```text
FUNCTION_NAME  default: jar-as-zip-demo
ROLE_NAME      default: lambda-java-runtime-examples-demo-role
RUNTIME        default: java17
HANDLER        default: example.TaskRootTreeHandler::handleRequest
```
