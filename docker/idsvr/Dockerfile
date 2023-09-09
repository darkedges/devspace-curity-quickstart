ARG CURITY_IMAGE=curity.azurecr.io/curity/idsvr
ARG CURITY_TAG=8.4.1

FROM alpine:latest as base
WORKDIR /tmp
RUN apk add git
RUN git clone https://github.com/curityio/kubernetes-quick-start.git
RUN find kubernetes-quick-start/haapi-web-example/ -type f | xargs sed -i 's/\.curity\.local/\.curity\.7f000001\.nip\.io/g'

FROM ${CURITY_IMAGE}:${CURITY_TAG}
# install MySQL jdbc connector
ADD --chown=idsvr:idsvr https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.1.0/mysql-connector-j-8.1.0.jar lib/plugins/data.access.jdbc
COPY idsvr/license.json /opt/idsvr/etc/init/license/
COPY --from=base --chown=idsvr:idsvr /tmp/kubernetes-quick-start/haapi-web-example/* /opt/idsvr/usr/share/webroot/
COPY --from=base --chown=idsvr:idsvr /tmp/kubernetes-quick-start/idsvr/log4j2.xml /opt/idsvr/etc/
COPY --chown=idsvr:idsvr idsvr/idsvr-config-backup.xml /opt/idsvr/etc/init/configmap-config.xml