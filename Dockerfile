ARG DISTRO=alpine
ARG DISTRO_TAG=3.14

FROM ${DISTRO}:${DISTRO_TAG}

ARG AS_PDNS_VERSION=1.6.1

ENV PDNS_setuid=${PDNS_setuid:-pdns} \
  PDNS_setgid=${PDNS_setgid:-pdns} \
  PDNS_daemon=${PDNS_daemon:-no} \
  AS_PDNS_VERSION=${AS_PDNS_VERSION}

RUN apk update \
  && apk add g++ make pkgconfig gnutls-dev libedit-dev fstrm-dev openssl-dev \
  h2o-dev libcap-dev libsodium-dev lmdb-dev net-snmp-dev nghttp2-dev \
  protobuf-dev re2-dev python3 py3-virtualenv py3-pip boost-dev \
  boost-serialization boost-system boost-thread boost-context lua5.3-dev \
  luajit-dev \
  && pip3 install --no-cache-dir envtpl

COPY src/dnsdist-${AS_PDNS_VERSION}.tar.bz2 /tmp/

COPY files/* /srv/

RUN mv /srv/entrypoint.sh / \
  && cat /tmp/dnsdist-${AS_PDNS_VERSION}.tar.bz2 | tar xj -C /tmp \
  && cd /tmp/dnsdist-${AS_PDNS_VERSION} \
  && ./configure --prefix=/usr --exec-prefix=/usr --sysconfdir=/etc/pdns \
  --enable-dnscrypt --enable-dns-over-tls --enable-dns-over-https --with-re2=yes \
  && make \
  && make install \
  && cd / \
  && rm -rf /tmp/dnsdist-${AS_PDNS_VERSION} \
  && mkdir -p /etc/pdns/conf.d \
  && mkdir -p /var/run/dnsdist \
  && addgroup ${PDNS_setgid} 2>/dev/null \
  && adduser -S -s /bin/false -H -h /tmp -G ${PDNS_setgid} ${PDNS_setuid} 2>/dev/null \
  && chown -R ${PDNS_setuid}:${PDNS_setgid} /etc/pdns/conf.d /var/run/dnsdist

EXPOSE 53/udp 53

ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["/usr/bin/dnsdist", "-l", "0.0.0.0:53", "--supervised"]
