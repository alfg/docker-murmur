ARG MUMBLE_VERSION=1.3.3

###############################
# Build the mumble-build image.
FROM ubuntu:20.04 as build-mumble
ARG MUMBLE_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	build-essential \
    ca-certificates \
    git \
	pkg-config \
	qt5-default \
	libboost-dev \
	libasound2-dev \
	libssl-dev \
	libspeechd-dev \
	libzeroc-ice-dev \
	libpulse-dev \
	libcap-dev \
	libprotobuf-dev \
	protobuf-compiler \
	protobuf-compiler-grpc \
	libprotoc-dev \
	libogg-dev \
	libavahi-compat-libdnssd-dev \
	libsndfile1-dev \
	libgrpc++-dev \
	libxi-dev \
	libbz2-dev \
	qtcreator

WORKDIR /root

RUN git clone --branch ${MUMBLE_VERSION} https://github.com/mumble-voip/mumble.git

RUN cd mumble && qmake -recursive main.pro CONFIG+="no-client grpc" && \
    make release

##########################
# Build the release image.
FROM ubuntu:20.04
LABEL MAINTAINER Alfred Gutierrez <alf.g.jr@gmail.com>

RUN adduser murmur
RUN apt-get update && apt-get install -y \
	libcap2 \
	libzeroc-ice3.7 \
	libprotobuf17 \
	libgrpc6 \
	libgrpc++1 \
	libavahi-compat-libdnssd1 \
	libqt5core5a \
	libqt5network5 \
	libqt5sql5 \
	libqt5xml5 \
	libqt5dbus5 \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=0 /root/mumble/release/murmurd /usr/bin/murmurd
COPY --from=0 /root/mumble/scripts/murmur.ini /etc/murmur/murmur.ini

RUN mkdir /var/lib/murmur && \
	chown murmur:murmur /var/lib/murmur && \
	sed -i 's/^database=$/database=\/var\/lib\/murmur\/murmur.sqlite/' /etc/murmur/murmur.ini

EXPOSE 64738/tcp 64738/udp 50051
USER murmur

CMD /usr/bin/murmurd -v -fg -ini /etc/murmur/murmur.ini