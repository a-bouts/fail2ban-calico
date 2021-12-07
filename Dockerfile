FROM debian as builder

ARG TARGETPLATFORM

#COPY ./aarch64-unknown-linux-gnu /target/aarch64-unknown-linux-gnu
#COPY ./x86_64-unknown-linux-gnu /target/x86_64-unknown-linux-gnu
COPY target/release/fail2ban-calico /target/x86_64-unknown-linux-gnu/release/

RUN if [ $TARGETPLATFORM = "linux/arm64" ]; then \
    mv /target/aarch64-unknown-linux-gnu/release/fail2ban-calico /fail2ban-calico; \
  elif [ $TARGETPLATFORM = "linux/amd64" ]; then \
    mv /target/x86_64-unknown-linux-gnu/release/fail2ban-calico /fail2ban-calico; \
  fi; \
  chmod +x /fail2ban-calico


FROM debian

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

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

COPY --from=builder /fail2ban-calico /usr/bin/

ENTRYPOINT [ "/init" ]
