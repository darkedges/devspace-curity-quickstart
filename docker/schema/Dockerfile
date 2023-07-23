ARG LIQUIBASE_IMAGE=liquibase/liquibase
ARG LIQUIBASE_TAG=4.23-alpine

FROM ${LIQUIBASE_IMAGE}:${LIQUIBASE_TAG}

COPY --chown=liquibase:liquibase changelog /liquibase/changelog

COPY --chown=liquibase:liquibase lib /liquibase/lib/

CMD ["sh", "-c", "docker-entrypoint.sh --log-level=${LOG_LEVEL} --driver=${DRIVER} --url=${URL} --username=\"${USERNAME}\" --password=${PASSWORD} --classpath=/liquibase/changelog --changeLogFile=${CHANGELOG_FILE} ${CMD}"]