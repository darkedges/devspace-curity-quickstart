# Docker: Curity Schema

This is a Curity Schema container, based on [Liquibase](https://www.liquibase.org/)

## Build

To build the container:

```console
git clone https://github.com/darkedges/devspace-curity-quickstart.git
cd devspace-curity-quickstart

# To build

docker build -t devspace-curity-quickstart/schema:8.4.1 --build-arg CURITY_TAG=8.4.1 docker/schema
```

## Run

### Mysql

```console
docker run -it --rm --name dcq-db -e "MYSQL_ROOT_PASSWORD=Passw0rd" -e "MYSQL_DATABASE=curity" -e "MYSQL_USER=curity" -e "MYSQL_PASSWORD=Passw0rd" --publish 3306:3306 mysql:8.0.33-oracle --log_bin_trust_function_creators=1
docker run -it --rm --link dcq-db:dcq-db --publish 8080:8080  -e "DRIVER=com.mysql.cj.jdbc.Driver" -e "URL=jdbc:mysql://dcq-db:3306/curity"-e "USERNAME=curity" -e "PASSWORD=Passw0rd" -e "CHANGELOG_FILE=changelog/mysql/install.xml" -e "LOG_LEVEL=INFO" -e "CMD=update" devspace-curity-quickstart/schema:8.4.1
```

### Explore

```console
docker run -it --rm --link dcq-db:dcq-db mysql:8.0.33-oracle mysql -u curity -h dcq-db -pPassw0rd curity -e 'show tables'
```

should return

```console
+--------------------------------+
| Tables_in_curity               |
+--------------------------------+
| DATABASECHANGELOG              |
| DATABASECHANGELOGLOCK          |
| accounts                       |
| audit                          |
| buckets                        |
| delegations                    |
| devices                        |
| dynamically_registered_clients |
| linked_accounts                |
| nonces                         |
| sessions                       |
| tokens                         |
+--------------------------------+
```

## Stop

```console
docker stop dcq-db
```

## Build Arguments

| build-arg         | Default Value         | Description |
| ----------------- | --------------------- | ----------- |
| `LIQUIBASE_IMAGE` | `liquibase/liquibase` | image name  |
| `LIQUIBASE_TAG`   | `4.23-alpine`         | tag value   |

## Folder Structure

### environmental variables

| Name             | Default Value | Description                                                                 |
| ---------------- | ------------- | --------------------------------------------------------------------------- |
| `CHANGELOG_FILE` |               | Change log to execute. e.g. ``                                              |
| `CMD`            |               | Liquibase command to execute. e.g. `update`                                 |
| `DRIVER`         |               | JDBC Driver. e.g. `com.mysql.cj.jdbc.Driver`                                |
| `LOG_LEVEL`      |               | Log level to use.g. `INFO`                                                  |
| `PASSWORD`       |               | Password to connect to database. e.g. `Passw0rd`                            |
| `URL`            |               | JDBC URL for connection to database. e.g. `jdbc:mysql://dcq-db:3306/curity` |
| `USERNAME`       |               | Change log to execute. e.g. `frim`                                          |

### instance

Contains the standard configuration folder structure for Curity.

| folder                   | description                                                                       |
| ------------------------ | --------------------------------------------------------------------------------- |
| [`changelog`](changelog) | Place the necessary SQL Files and Liquibase change log files here.                |
| [`lib`](lib)             | This contains the JDBC Connector Library. This example includes the one for MySQL |
