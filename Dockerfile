FROM debian:bookworm-slim AS base

# Install required packages
RUN --mount=type=bind,source=/scripts,target=/scripts \
    sh /scripts/install.sh

FROM base

# Copy postfix configuration files
COPY config/main.cf             /etc/postfix/main.cf
COPY scripts/                   /scripts

RUN chmod +x /scripts/*

USER root
WORKDIR /tmp

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --start-interval=2s --retries=3 CMD /scripts/healthcheck.sh

# Expose SMTP ports
EXPOSE 25 587

CMD [ "/bin/sh", "-c", "/scripts/run.sh" ]
