ARG MUMBLE_VERSION=master

###############################
# Build the mumble-build image.
FROM ubuntu:20.04 as build-mumble
ARG MUMBLE_VERSION

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    cmake \
    ca-certificates \
    git \
    pkg-config \
    qt5-default \
    qttools5-dev \
    qttools5-dev-tools \
    libqt5svg5-dev \
    libboost-dev \
    libssl-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libprotoc-dev \
    libcap-dev \
    libxi-dev \
    libasound2-dev \
    libogg-dev \
    libsndfile1-dev \
    libspeechd-dev \
    libavahi-compat-libdnssd-dev \
    libzeroc-ice-dev \
    g++-multilib \
    libgrpc++-dev \
    protobuf-compiler-grpc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN git clone --branch ${MUMBLE_VERSION} https://github.com/mumble-voip/mumble.git

RUN cd mumble && mkdir build && cd build && \
    cmake -Dclient=OFF -DCMAKE_BUILD_TYPE=Release -Dgprc=ON -Dstatic=ON .. && \
    make -j $(nproc)

#########################
# Build the relase image.
FROM ubuntu:latest
LABEL MAINTAINER Alfred Gutierrez <alf.g.jr@gmail.com>

RUN adduser murmur
RUN apt-get update && apt-get install --no-install-recommends -y \
	libcap2 \
	libzeroc-ice3.7 \
	'^libprotobuf[0-9]+$' \
	'^libgrpc[0-9]+$' \
	libgrpc++1 \
	libavahi-compat-libdnssd1 \
	libqt5core5a \
	libqt5network5 \
	libqt5sql5 \
	libqt5xml5 \
	libqt5dbus5 \
	ca-certificates \
    sqlite3 \
    libsqlite3-dev \
	&& rm -rf /var/lib/apt/lists/* 

COPY --from=0 /root/mumble/build/murmurd /usr/bin/murmurd
COPY --from=0 /root/mumble/scripts/murmur.ini /etc/murmur/murmur.ini
# COPY --from=0 /root/mumble/build/* /test/

RUN mkdir /var/lib/murmur && \
	chown murmur:murmur /var/lib/murmur && \
	sed -i 's/^database=$/database=\/var\/lib\/murmur\/murmur.sqlite/' /etc/murmur/murmur.ini

EXPOSE 64738/tcp 64738/udp 50051
USER murmur

CMD /usr/bin/murmurd -v -fg -ini /etc/murmur/murmur.ini