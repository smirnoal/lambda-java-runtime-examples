FROM public.ecr.aws/lambda/java:17

COPY build/libs/function.jar ${LAMBDA_TASK_ROOT}/lib/
COPY build/dependency/* ${LAMBDA_TASK_ROOT}/lib/

RUN chmod 000 ${LAMBDA_TASK_ROOT}/lib/gson-*.jar

CMD ["example.TaskRootPermissionsHandler::handleRequest"]
