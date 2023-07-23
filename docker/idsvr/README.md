# Docker: Curity Server

This is a Curity container, based on [Curity](https://www.curity.io/)

## Build

To build the container:

```console
git clone https://github.com/darkedges/devspace-curity-quickstart.git
cd devspace-curity-quickstart

# To build

docker build -t devspace-curity-quickstart/idsvr:8.3.1 docker/idsvr
```

## Pre-requisites

requires a MySQL Database installed and Schema deployed. Follow the documentation in [schema/README.md](../schema/README.md)

## Run

```console
docker run -it --rm --link dcq-db:dcq-db -e PASSWORD=Passw0rd -p 6749:6749 -p 8443:8443 devspace-curity-quickstart/idsvr:8.3.1
```
