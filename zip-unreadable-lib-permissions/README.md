# Unreadable Library Permissions

This example creates a Java Lambda deployment archive with one dependency JAR stored under `lib/` with Unix permissions set to `000`.

The handler prints a recursive tree of `/var/task` with POSIX permissions, so you can compare what Lambda exposes right after deployment and after Lambda's asynchronous optimization step has had time to finish.

## What This Tests

The built `function.jar` contains:

```text
lib/function.jar
lib/aws-lambda-java-core-1.4.0.jar
lib/gson-2.14.0.jar  # stored in the archive with mode 000
```

The handler itself does not use Gson. Gson is included only as a dependency JAR whose permissions are intentionally wrong.

## Run

```sh
./0-init.sh
./1-deploy.sh
./2-invoke.sh
```

If the function is invokable, the response looks like:

```text
rwxr-xr-x /var/task
`-- rwxr-xr-x lib/
    |-- rwxr-xr-x function.jar
    |-- rwxr-xr-x aws-lambda-java-core-1.4.0.jar
    `-- rwxr-xr-x gson-2.14.0.jar
```

For ZIP deployments, Lambda normalizes permissions on the prepared `/var/task` tree. The local archive still stores `gson-2.14.0.jar` with mode `000`, but after deployment you should see readable/executable bits on all entries. Compare with the container-image example, which preserves bad permissions.

Invoke once immediately after deployment, then invoke again after some time and compare the permissions.

## Inspect the Local Archive

Depending on your local tools, one of these commands can show the stored archive modes:

```sh
zipinfo -l build/libs/function.jar
```

```sh
unzip -Z -l build/libs/function.jar
```

## Cleanup

```sh
./3-cleanup.sh
```

By default cleanup deletes only the function and keeps the shared demo role for future examples. To delete the role too:

```sh
DELETE_ROLE=true ./3-cleanup.sh
```
