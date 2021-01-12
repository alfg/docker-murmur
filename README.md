# Docker Murmur
A Dockerfile with Mumble Server (murmur) built from source with gRPC support enabled.

[![Docker Stars](https://img.shields.io/docker/stars/alfg/murmur.svg)](https://hub.docker.com/r/alfg/murmur/)
[![Docker Pulls](https://img.shields.io/docker/pulls/alfg/murmur.svg)](https://hub.docker.com/r/alfg/murmur/)
[![Docker Automated build](https://img.shields.io/docker/automated/alfg/murmur.svg)](https://hub.docker.com/r/alfg/murmur/builds/)
[![Build Status](https://travis-ci.org/alfg/docker-murmur.svg?branch=master)](https://travis-ci.org/alfg/docker-murmur)

## Usage

### Setup
* Pull docker image and run:
```
docker pull alfg/murmur
docker run -it -p 50051:50051 --rm alfg/murmur
```

* Or build and run container from source:
```
git clone https://github.com/alfg/docker-murmur.git && cd docker-murmur
docker build -t murmur .
docker run -it -p 50051:50051 --rm alfg/murmur
```

### Connect with Mumble
```
server: localhost
port:   64738
```

Direct Link: `mumble://localhost:64738`

### Custom `murmur.ini`
If you wish to use your own `murmur.ini`, mount it as a volume in your `docker-compose` file or `docker` command:

```yaml
volumes:
  - ./murmur.ini:/etc/murmur/murmur.ini
``` 

### gRPC
`gRPC` is enabled by default by connecting to: `127.0.0.1:50051`


## TODO
* Custom `murmur.ini`
* Virtual servers
* SuperUser setup

## Resources
* https://github.com/mumble-voip/mumble/blob/master/docs/dev/build-instructions/build_linux.md
