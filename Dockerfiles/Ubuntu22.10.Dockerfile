FROM ubuntu:22.10

RUN mkdir -p /app && apt-get update \
    && apt-get install -y libmicrohttpd-dev libjansson-dev libssl-dev libsrtp2-dev libsofia-sip-ua-dev libglib2.0-dev \
    libopus-dev libogg-dev libcurl4-openssl-dev liblua5.3-dev libconfig-dev pkg-config libtool automake autoconf git \
    cmake meson ninja-build \
    # Install libnice because the available version in Ubuntu usually case problems.
    && cd / && git clone https://gitlab.freedesktop.org/libnice/libnice && cd libnice \
    && meson --prefix=/usr build && ninja -C build && ninja -C build install \
    # Install usrsctp
    && cd / && git clone https://github.com/sctplab/usrsctp && cd usrsctp && ./bootstrap \
    && ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && make && make install \
    # Install MQTT
    && cd / && git clone https://github.com/eclipse/paho.mqtt.c.git && cd paho.mqtt.c && make && make install \
    && apt-get install -y libnanomsg-dev \
    && cd / && git clone https://github.com/alanxz/rabbitmq-c && cd rabbitmq-c && git submodule init && git submodule update \
	&& mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr .. && make && make install \
    # Install Libwebsockets
    #   If libwebsockets.org cannot be reached, please use https://github.com/warmcat/libwebsockets.git
    #   See https://github.com/meetecho/janus-gateway/issues/732 re: LWS_MAX_SMP
    #   See https://github.com/meetecho/janus-gateway/issues/2476 re: LWS_WITHOUT_EXTENSIONS
    && cd / && git clone https://libwebsockets.org/repo/libwebsockets \
    && cd libwebsockets && mkdir build && cd build \
    && cmake -DLWS_MAX_SMP=1 -DLWS_WITHOUT_EXTENSIONS=0 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. \
    && make && make install \
    # Install Janus
    && cd / && git clone https://github.com/meetecho/janus-gateway.git && cd janus-gateway && sh autogen.sh \
    && ./configure --prefix=/app/janus && make && make install && make configs

WORKDIR /app
ENTRYPOINT [ "janus" ]