FROM debian as builder

ARG TARGETPLATFORM

COPY ./aarch64-unknown-linux-gnu /target/aarch64-unknown-linux-gnu

RUN if [ $TARGETPLATFORM = "linux/arm64" ]; then \
    mv /target/aarch64-unknown-linux-gnu/release/fail2ban-calico /fail2ban-calico; \
  elif [ $TARGETPLATFORM = "linux/amd64" ]; then \
    mv /target/x86_64-unknown-linux-gnu/release/fail2ban-calico /fail2ban-calico; \
  fi; \


FROM debian

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y -q && \
    apt-get install -y -q --no-install-recommends\
    fail2ban \
    exim4 \
    bsd-mailx \
    whois \
    && rm -rf /var/lib/apt/lists/* \

COPY --from=builder /fail2ban-calico /usr/bin/


CMD ["/races"]
