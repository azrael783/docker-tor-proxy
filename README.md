<p align="center">
  <img width="300px" src="https://upload.wikimedia.org/wikipedia/commons/8/8f/Tor_project_logo_hq.png">
</p>

# Tor-socks-proxy

![license](https://img.shields.io/badge/license-GPLv3.0-brightgreen.svg?style=flat)
[![Docker Hub pulls](https://img.shields.io/docker/pulls/x86txt/tor-socks-proxy.svg)](https://hub.docker.com/r/x86txt/tor-socks-proxy/)
[![Docker image layers](https://images.microbadger.com/badges/image/x86txt/tor-socks-proxy.svg)](https://microbadger.com/images/x86txt/tor-socks-proxy/)
[![Docker image version](https://images.microbadger.com/badges/version/x86txt/tor-socks-proxy.svg)](https://hub.docker.com/r/x86txt/tor-socks-proxy/tags/)

[![Docker Hub badge](http://dockeri.co/image/x86txt/tor-socks-proxy)](https://hub.docker.com/r/x86txt/tor-socks-proxy/)

The super easy way to setup a [Tor](https://www.torproject.org) [SOCKS5](https://en.wikipedia.org/wiki/SOCKS#SOCKS5) [proxy server](https://en.wikipedia.org/wiki/Proxy_server) inside a [Docker](https://en.wikipedia.org/wiki/Docker_(software)) [container](https://en.wikipedia.org/wiki/Container_(virtualization)), \***without**\* the relay/exit feature. 

> Modified from [PeterDaveHello/tor-socks-proxy](https://github.com/PeterDaveHello/tor-socks-proxy) by rebasing to Ubuntu 20.04 and pulling the latest Tor daemon directly from the Tor Project's apt repo.

## Usage

1. Setup the proxy server at the **first time**

    ```sh
    $ docker run -d --restart=always --name tor-socks-proxy -p 0.0.0.0:9150:9150/tcp x86txt/tor-socks-proxy:latest
    ```

    - With parameter `--restart=always` the container will always start on daemon startup, which means it'll automatically start after system reboot.
    - Use `0.0.0.0` to listen on all IPs and accept connections from anywhere - **MAKE SURE YOU FIREWALL THIS CONTAINER FROM THE PUBLIC INTERNET**!
    - Change to first `9150` to any valid and free port you want, please note that port `9050`/`9150` may already taken if you are also running other Tor client, like TorBrowser.
    - Do not touch the second `9150` as it's the port inside the docker container unless you're going to change the port in Dockerfile.

    If you want to expose Tor's DNS port, also add `-p 0.0.0.0:53:53/udp` in the command, see [DNS over Tor](#dns-over-tor) for more details.

    If you already setup the instance before *(not the first time)* but it's in stopped state, you can just start it instead of creating a new one:

    ```sh
    $ docker start tor-socks-proxy
    ```

2. Make sure it's running, it'll take a short time to bootstrap

    ```sh
    $ docker logs tor-socks-proxy
    .
    .
    .
    Jan 10 01:06:59.000 [notice] Bootstrapped 85%: Finishing handshake with first hop
    Jan 10 01:07:00.000 [notice] Bootstrapped 90%: Establishing a Tor circuit
    Jan 10 01:07:02.000 [notice] Tor has successfully opened a circuit. Looks like client functionality is working.
    Jan 10 01:07:02.000 [notice] Bootstrapped 100%: Done
    ```

3. Configure your client to use it, target your Docker host's IP or FQDN using port `9150`(Or the other port you setup in step 1)

    Take `curl` as an example, checkout what's your IP address via Tor network using one of the following IP checking services:

    ```sh
    $ curl --socks5-hostname your.docker.host.ip:9150 https://ipinfo.tw/ip
    $ curl --socks5-hostname your.docker.host.ip:9150 https://ipinfo.io/ip
    $ curl --socks5-hostname your.docker.host.ip:9150 https://icanhazip.com
    $ curl --socks5-hostname your.docker.host.ip:9150 https://ipecho.net/plain
    ```

    Take `ssh` and `nc` as an example, connect to a host via Tor:

    ```sh
    $ ssh -o ProxyCommand='nc -x your.docker.host.ip:9150 %h %p' target.hostname.blah
    ```

4. After using it, you can turn it off

    ```sh
    $ docker stop tor-socks-proxy
    ```

## DNS over Tor

If you publish the DNS port in the first step of [Usage](#usage) section, you can query DNS request over Tor.

This port only handles A, AAAA, and PTR requests, see details on [official manual](https://www.torproject.org/docs/tor-manual.html.en)

Set the DNS server to `your.docker.host.ip` (Or another IP you set), use [macvk/dnsleaktest](https://github.com/macvk/dnsleaktest) or go to one of the following DNS leaking test websites to verify the result:

- DNS leak test: <https://www.dnsleaktest.com>
- IP Leak Tests: <https://ipleak.org/>
- IP/DNS Detect: <https://ipleak.net/>
