# syntax=docker/dockerfile:1.7
#
# static-site — hardened, non-root nginx (with brotli) base for prplanit static sites.
#
# Consumers are 2-liners:
#     FROM cr.pcfae.com/prplanit/static-site:vX.Y.Z
#     COPY www-data/ /usr/share/nginx/html/
#
# nginx + the brotli module come from Alpine's own repo (main), pinned to an exact
# version-revision. The brotli DYNAMIC module must be ABI-matched to the nginx build,
# so both share NGINX_VERSION — never bump one without the other. Same sourcing as
# nginx-extras-oci, kept consistent. Both pins are piloted by StageFreight deps
# (dependency.scope.dockerfile_env).
ARG ALPINE_VERSION=3.23.5
FROM docker.io/library/alpine:${ALPINE_VERSION}

# nginx and its brotli module — MUST stay the same version-revision (module ABI match).
ARG NGINX_VERSION=1.28.3-r7

LABEL org.opencontainers.image.title="static-site" \
      org.opencontainers.image.description="Hardened non-root nginx (brotli) base for prplanit static sites" \
      org.opencontainers.image.source="https://gitlab.prplanit.com/PrPlanIT/static-site" \
      org.opencontainers.image.vendor="PrPlanIT" \
      org.opencontainers.image.licenses="MIT"

# Runtime-tunable (consumers / k8s can override)
ENV LISTEN_PORT=8080 \
    LOG_LEVEL=warn \
    WORKER_PROCESSES=auto

RUN set -eux; \
    # refresh base OS packages: fresh CVE patches at build time, within the pinned Alpine
    apk upgrade --no-cache; \
    # nginx + brotli module, pinned to the same version-revision (ABI-compatible)
    apk add --no-cache \
        "nginx=${NGINX_VERSION}" \
        "nginx-mod-http-brotli=${NGINX_VERSION}" \
        ca-certificates tzdata gettext; \
    # non-root runtime user
    addgroup -g 10001 -S web; \
    adduser -u 10001 -S -G web -H -s /sbin/nologin web; \
    # html root (content COPYd in by consumers; pid/temp/conf render to /tmp at runtime)
    mkdir -p /usr/share/nginx/html; \
    chown -R web:web /usr/share/nginx/html; \
    rm -rf /var/cache/apk/*

# Hardened config as templates — the entrypoint envsubst's them into /tmp at startup,
# so the container runs fine with readOnlyRootFilesystem: true.
COPY nginx.conf     /etc/nginx/nginx.conf.template
COPY default.conf   /etc/nginx/conf.d/default.conf.template
COPY entrypoint.sh  /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
USER web
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/entrypoint.sh"]
