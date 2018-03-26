#!/bin/sh

# REQUIRE: NETWORKING

set -e

ARCH=${ARCH:='arm'}
DNSCRYPT_PROXY_PORT=53
DNSCRYPT_PROXY_VERSION='2.0.8'
OS=${OS:='freebsd'}

cd /tmp || exit 255

mkdir -p /usr/local/etc/dnscrypt-proxy

if [ ! -f /usr/local/bin/dnscrypt-proxy ] ||
  ! /usr/local/bin/dnscrypt-proxy -version | grep -q "$DNSCRYPT_PROXY_VERSION"; then
  fetch -m "https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-freebsd_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz"

  tmp_directory=$(mktemp -d)
  tar -zxf "dnscrypt-proxy-freebsd_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz" \
    -C "$tmp_directory"

  rm -f "dnscrypt-proxy-freebsd_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz"
  mv "${tmp_directory}/freebsd-arm/dnscrypt-proxy" /usr/local/bin/dnscrypt-proxy
  rm -rf "${tmp_directory}"

  chown root:root /usr/local/bin/dnscrypt-proxy
  chmod +x /usr/local/bin/dnscrypt-proxy
fi

fetch -m https://download.dnscrypt.info/blacklists/domains/mybase.txt \
  -o /usr/local/etc/dnscrypt-proxy/blacklist.txt

cat <<DNSCRYPT-PROXY > /usr/local/etc/dnscrypt-proxy/dnscrypt-proxy.toml
block_ipv6 = false
cache = true
cache_max_ttl = 86400
cache_min_ttl = 600
cache_neg_ttl = 60
cache_size = 16000
cert_refresh_delay = 30
daemonize = false
dnscrypt_servers = true
doh_servers = true
fallback_resolver = '9.9.9.9:53'
force_tcp = false
ignore_system_dns = true
ipv4_servers = true
ipv6_servers = false
lb_strategy = 'p2'
listen_addresses = ["0.0.0.0:${DNSCRYPT_PROXY_PORT}"]
max_clients = 100
require_dnssec = false
require_nofilter = true
require_nolog = true
timeout = 3000

[query_log]
  file = "/dev/null"
  format = "tsv"

[blacklist]
  blacklist_file = '/usr/local/etc/dnscrypt-proxy/blacklist.txt'
  log_file = '/dev/null'

[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v2/public-resolvers.md', 'https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md']
  cache_file = '/tmp/public-resolvers.md'
  format = 'v2'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
  prefix = ''

[schedules]
  [schedules.'time-to-sleep']
  mon = [{after='23:00', before='7:00'}]
  tue = [{after='23:00', before='7:00'}]
  wed = [{after='23:00', before='7:00'}]
  thu = [{after='23:00', before='7:00'}]
  fri = [{after='00:00', before='7:00'}]
  sat = [{after='00:00', before='7:00'}]
  sun = [{after='23:00', before='7:00'}]

  [schedules.'work']
  mon = [{after='9:00', before='18:00'}]
  tue = [{after='9:00', before='18:00'}]
  wed = [{after='9:00', before='18:00'}]
  thu = [{after='9:00', before='18:00'}]
  fri = [{after='9:00', before='17:00'}]
DNSCRYPT-PROXY

exec /usr/local/bin/dnscrypt-proxy \
  -config /usr/local/etc/dnscrypt-proxy/dnscrypt-proxy.toml
