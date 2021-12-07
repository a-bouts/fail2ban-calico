FROM debian as debian-arm64

ARG FAIL2BAN_CALICO=./aarch64-unknown-linux-gnu/release/fail2ban-calico
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-aarch64.tar.gz


FROM debian as debian-amd64

ARG FAIL2BAN_CALICO=./x86_64-unknown-linux-gnu/release/fail2ban-calico
ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz


FROM debian-${TARGETARCH}

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends\
    fail2ban \
    exim4 \
    bsd-mailx \
    whois \
    && rm -rf /var/lib/apt/lists/*

ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

RUN tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

ADD rootfs /

COPY ${FAIL2BAN_CALICO} /usr/bin/
RUN chmod +x /usr/bin/fail2ban-calico

ENTRYPOINT [ "/init" ]
