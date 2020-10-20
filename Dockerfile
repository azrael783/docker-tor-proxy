FROM ubuntu:20.04

LABEL maintainer="Matthew Evans <matt@x86txt.com>"
LABEL version="0.1"
LABEL name="tor-socks-proxy"
LABEL description="A simple tor socks proxy running official Tor Project packages."
LABEL version="latest"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install curl gpg apt-transport-https -y && \
    echo 'deb https://deb.torproject.org/torproject.org focal main' >> /etc/apt/sources.list.d/tor.list && \
    echo 'deb-src https://deb.torproject.org/torproject.org focal main' >> /etc/apt/sources.list.d/tor.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 74A941BA219EC810 && \
    apt update && apt install tor deb.torproject.org-keyring -y && \
    chmod 700 /var/lib/tor && \
    rm -rf /var/lib/apt/lists/* && \
    apt clean && \
    tor --version

COPY torrc /etc/tor/

HEALTHCHECK --timeout=10s --start-period=60s \
    CMD curl --fail --socks5-hostname localhost:9150 -I -L 'https://www.facebookcorewwwi.onion/' || exit 1

EXPOSE 53/udp 9150/tcp

CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
