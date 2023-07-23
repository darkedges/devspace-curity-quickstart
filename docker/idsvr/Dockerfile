ARG CURITY_IMAGE=curity.azurecr.io/curity/idsvr
ARG CURITY_TAG=8.3.1

FROM ${CURITY_IMAGE}:${CURITY_TAG}
# install MySQL jdbc connector
ADD --chown=idsvr:idsvr https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.1.0/mysql-connector-j-8.1.0.jar lib/plugins/data.access.jdbc