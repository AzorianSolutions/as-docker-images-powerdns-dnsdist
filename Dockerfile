ARG DISTRO=debian
ARG DISTRO_TAG=11.1-slim

FROM ${DISTRO}:${DISTRO_TAG}

ARG AS_PDNS_VERSION=1.6.1

ENV PDNS_setuid=${PDNS_setuid:-pdns} \
  PDNS_setgid=${PDNS_setgid:-pdns} \
  PDNS_daemon=${PDNS_daemon:-no} \
  AS_PDNS_VERSION=${AS_PDNS_VERSION}

RUN apt update \
  && apt -y install g++ make pkg-config libssl-dev libsnmp-dev gnutls-dev \
  libedit-dev libfstrm-dev libssl-dev libh2o-dev libh2o-evloop-dev libcap-dev \
  libsodium-dev liblmdb-dev libsnmp-dev libnghttp2-dev libprotobuf-dev \
  libre2-dev python3-venv python3-pip libboost-dev libboost-serialization-dev \
  libboost-system-dev libboost-thread-dev libboost-context-dev \
  libluajit-5.1-dev \
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
  && adduser --system --disabled-login --no-create-home --home /tmp --shell /bin/false --group ${PDNS_setgid} 2>/dev/null \
  && chown -R ${PDNS_setuid}:${PDNS_setgid} /etc/pdns/conf.d /var/run/dnsdist

EXPOSE 53/udp 53

ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["/usr/bin/dnsdist", "-l", "0.0.0.0:53", "--supervised"]
