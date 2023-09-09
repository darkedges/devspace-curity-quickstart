ARG LIQUIBASE_IMAGE=liquibase/liquibase
ARG LIQUIBASE_TAG=4.23-alpine

ARG CURITY_IMAGE=curity.azurecr.io/curity/idsvr
ARG CURITY_TAG=8.4.1

FROM ${CURITY_IMAGE}:${CURITY_TAG} as base

FROM ${LIQUIBASE_IMAGE}:${LIQUIBASE_TAG}
COPY --chown=liquibase:liquibase changelog /liquibase/changelog
COPY --chown=liquibase:liquibase lib /liquibase/lib/
COPY --from=base --chown=liquibase:liquibase /opt/idsvr/etc/postgres-create_database.sql /liquibase/changelog/postgres/create_database.sql
COPY --from=base --chown=liquibase:liquibase /opt/idsvr/etc/oracle-create_database.sql /liquibase/changelog/oracle/create_database.sql
COPY --from=base --chown=liquibase:liquibase /opt/idsvr/etc/mssql-create_database.sql /liquibase/changelog/mssql/create_database.sql
COPY --from=base --chown=liquibase:liquibase /opt/idsvr/etc/mysql-create_database.sql /liquibase/changelog/mysql/create_database.sql
RUN sed -i '/^DELIMITER ;;$/d' /liquibase/changelog/mysql/create_database.sql && \
    sed -i '/^;;$/c\;' /liquibase/changelog/mysql/create_database.sql
CMD ["sh", "-c", "docker-entrypoint.sh --log-level=${LOG_LEVEL} --driver=${DRIVER} --url=${URL} --username=\"${USERNAME}\" --password=${PASSWORD} --classpath=/liquibase/changelog --changeLogFile=${CHANGELOG_FILE} ${CMD}"]