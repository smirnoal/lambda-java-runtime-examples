# Lambda Java Runtime Examples

Small, focused examples for understanding how Java code runs on AWS Lambda.

The repo is intentionally flat: each top-level directory is one self-contained example with its own build file, scripts, and README.

## Examples

- [`jar-as-zip`](jar-as-zip/) — builds a deployable `.jar` that Lambda accepts through `--zip-file`, with handler classes at the archive root and dependencies under `lib/`.

## Script Convention

Examples use numbered shell scripts for repeatable demos:

```text
0-init.sh     create or verify shared demo infrastructure
1-deploy.sh   build and deploy the example
2-invoke.sh   invoke the deployed function
3-cleanup.sh  remove deployed resources
```

The scripts use AWS CLI credentials from your current shell environment.
