# static-site — Project Instructions

Hardened, non-root **nginx** (brotli) base image for prplanit static sites. Consumer site
repos are `FROM cr.pcfae.com/prplanit/static-site:<tag>` + `COPY www-data/ /usr/share/nginx/html/`
— they carry only static assets; all nginx/hardening policy lives here.

## Non-negotiables

- **Non-root.** Runs as uid 10001 on `:8080`. Never reintroduce root or a privileged port.
- **Pins move together.** `NGINX_VERSION` drives BOTH `nginx` and `nginx-mod-http-brotli` — the
  dynamic brotli module is ABI-locked to the nginx build, so bump them as a unit, never
  independently. `ALPINE_VERSION` is the OS floor.
- **Read-only friendly.** pid / temp / rendered config all go to `/tmp` so consumers can set
  `readOnlyRootFilesystem: true`. Keep it that way.
- **Config is templated.** `nginx.conf`/`default.conf` are `.template`s; `entrypoint.sh`
  envsubst's `${LISTEN_PORT}`/`${LOG_LEVEL}`/`${WORKER_PROCESSES}` into `/tmp` at startup.
- **Deps are piloted by StageFreight** (`dependency.scope.dockerfile_env`), NOT Renovate.
- **`.gitlab-ci.yml` is SF-generated** (`stagefreight ci render gitlab --write`) — never hand-edit.
- **License**: repo files MIT; bundled software keeps its own licenses (see LICENSE). Don't
  relicense nginx et al.

## Not this repo's job

TLS, Cloudflare real-IP, geoip, reverse-proxy modules, dhparam — that's the gateway
(`nginx-extras-oci`), which runs root on :80/:443. This image is content behind the gateway.
