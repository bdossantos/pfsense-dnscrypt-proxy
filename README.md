# pfsense-dnscrypt-proxy

These instructions apply to [dnscrypt-proxy](https://github.com/jedisct1/dnscrypt-proxy)
version 2 and are tested on pfSense 2.4.

There are two approaches:

1) have clients talk directly to dnscrypt-proxy from the network
2) use the built in unbound forwarder in pfSense.

The latter makes it possible to use extra functionality like registering DHCP
hostnames in DNS.

## Installation

```sh
fetch https://raw.githubusercontent.com/bdossantos/pfsense-dnscrypt-proxy/master/dnscrypt-proxy.sh \
  -o /usr/local/etc/rc.d/dnscrypt-proxy.sh
chmod +x /usr/local/etc/rc.d/dnscrypt-proxy.sh
```

## Run

### Using dnscrypt-proxy directly

Note down the IP adresses of the interfaces you want dnscrypt-proxy to listen on,
to put in the configuration file.

Make sure both **DNS Forwarder** and **DNS Resolver** are disabled.

### Using both dnscrypt-proxy and the built-in DNS Forwarder (unbound)

Add a new virtual IP in "Firewall->Virtual IPs" in the pfSense GUI:

* Type: `IP Alias`
* Interface: `Localhost`
* IP address: `127.0.0.2/32`

Configure "Services -> DNS Forwarder" in the pfSense GUI:

* Interfaces: Select all needed except for the `127.0.0.2` VIP interface.
* Strict interface binding: `true`
