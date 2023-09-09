# Docker: Curity Server

This is a Curity container, based on [Curity](https://www.curity.io/)

## Pre-requisites

- requires a MySQL Database installed and Schema deployed. Follow the documentation in [schema/README.md](../schema/README.md)
- A license file that can be downloade from [https://developer.curity.io/licenses](https://developer.curity.io/licenses)
  - Create a new license by clicking `Request a new license`
  - Download an existing license to [idsvr/license.json](idsvr/license.json)


## Build

To build the container:

```console
git clone https://github.com/darkedges/devspace-curity-quickstart.git
cd devspace-curity-quickstart

# To build

docker build -t devspace-curity-quickstart/idsvr:8.3.1 docker/idsvr
```

## Run

```console
docker run -it --rm --link dcq-db:dcq-db -e PASSWORD=Passw0rd -p 6749:6749 -p 8443:8443 devspace-curity-quickstart/idsvr:8.3.1
```
