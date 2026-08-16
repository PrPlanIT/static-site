# syntax=docker/dockerfile:1.7
#
# static-site — hardened, non-root nginx (with brotli) base for prplanit static sites.
#
# Consumers are 2-liners:
#     FROM docker.io/prplanit/static-site:vX.Y.Z
#     COPY www-data/ /usr/share/nginx/html/
#
# The Alpine base is the single pinned anchor — pinned by TAG + DIGEST (immutable,
# reproducible foundation), piloted by StageFreight deps (bumps the tag AND re-resolves
# the digest). nginx + its brotli module come from Alpine's repo unpinned and are
# refreshed at build (apk upgrade), so CVE patches ride in on every rebuild; the exact
# versions shipped are recorded in the SBOM. nginx + nginx-mod-http-brotli install from
# the same Alpine repo, so they stay ABI-matched automatically.
FROM docker.io/library/alpine:3.23.5@sha256:1beb0dc0a51de7ff38e3b5274078a2e0b81113ba5c7535e1a03d5913a5edbda3

LABEL org.opencontainers.image.title="static-site" \
      org.opencontainers.image.description="Hardened non-root nginx (brotli) base image for prplanit static sites" \
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
    # nginx + its brotli module (same Alpine repo → ABI-matched) + runtime deps
    apk add --no-cache \
        nginx \
        nginx-mod-http-brotli \
        ca-certificates \
        tzdata \
        gettext; \
    # non-root runtime user
    addgroup -g 10001 -S web; \
    adduser -u 10001 -S -G web -H -s /sbin/nologin web; \
    # html root (content COPYd in by consumers; pid/temp/conf render to /tmp at runtime)
    mkdir -p /usr/share/nginx/html; \
    chown -R web:web /usr/share/nginx/html; \
    rm -rf /var/cache/apk/*

# Hardened config as templates — the entrypoint envsubst's them into /tmp at startup,
# so the container runs fine with readOnlyRootFilesystem: true.
COPY nginx/nginx.conf    /etc/nginx/nginx.conf.template
COPY nginx/default.conf  /etc/nginx/conf.d/default.conf.template
COPY nginx/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
USER web
STOPSIGNAL SIGQUIT
ENTRYPOINT ["/entrypoint.sh"]
