# static-site

Hardened, non-root **nginx** (with brotli) base image for prplanit static sites. Consumer repos are two-liners — `FROM` this image and `COPY` your static assets — and inherit non-root, `readOnlyRootFilesystem`-friendly, pinned, and security-scanned defaults.

<!-- sf:project:start -->
[![GitHub](https://img.shields.io/badge/GitHub-source-181717?logo=github)](https://github.com/PrPlanIT/static-site) [![GitLab](https://img.shields.io/badge/GitLab-source-FC6D26?logo=gitlab)](https://gitlab.prplanit.com/PrPlanIT/static-site) [![Last Commit](https://img.shields.io/github/last-commit/PrPlanIT/static-site)](https://github.com/PrPlanIT/static-site/commits) [![Open Issues](https://img.shields.io/github/issues/PrPlanIT/static-site)](https://github.com/PrPlanIT/static-site/issues) [![Open PRs](https://img.shields.io/github/issues-pr/PrPlanIT/static-site)](https://github.com/PrPlanIT/static-site/pulls) [![Contributors](https://img.shields.io/github/contributors/PrPlanIT/static-site)](https://github.com/PrPlanIT/static-site/graphs/contributors)
<!-- sf:project:end -->
<!-- sf:badges:start -->
[![build](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/build.svg)](https://gitlab.prplanit.com/PrPlanIT/static-site/-/pipelines) [![license](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/license.svg)](https://github.com/PrPlanIT/static-site/blob/main/LICENSE) [![release](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/release.svg)](https://github.com/PrPlanIT/static-site/releases) ![updated](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/updated.svg) [![donate](https://img.shields.io/badge/donate-FF5E5B?logo=ko-fi&logoColor=white)](https://ko-fi.com/T6T41IT163) [![sponsor](https://img.shields.io/badge/sponsor-EA4AAA?logo=githubsponsors&logoColor=white)](https://github.com/sponsors/PrPlanIT)
<!-- sf:badges:end -->
<!-- sf:image:start -->
[![Docker](https://img.shields.io/badge/Docker-prplanit%2Fstatic--site-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/prplanit/static-site) [![pulls](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/pulls.svg)](https://hub.docker.com/r/prplanit/static-site)

[![latest](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/release-latest.svg)](https://hub.docker.com/r/prplanit/static-site/tags?name=latest) ![updated](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/release-updated.svg) [![size](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/release-size.svg)](https://hub.docker.com/r/prplanit/static-site/tags?name=v0.0.2) [![latest-dev](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/dev-latest.svg)](https://hub.docker.com/r/prplanit/static-site/tags?name=latest-dev) ![updated](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/dev-updated.svg) [![size](https://raw.githubusercontent.com/PrPlanIT/static-site/main/.stagefreight/scribe/dev-size.svg)](https://hub.docker.com/r/prplanit/static-site/tags?name=latest-dev)
<!-- sf:image:end -->

## Image contents

Base:
<!-- sf:contents-base:start -->
[![alpine 3.23.5](https://img.shields.io/badge/alpine-3.23.5-0078D4?style=flat)](https://hub.docker.com/_/alpine)
<!-- sf:contents-base:end -->

Packages:
<!-- sf:contents-apk:start -->
[![ca-certificates](https://img.shields.io/badge/ca--certificates-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=ca-certificates) [![gettext](https://img.shields.io/badge/gettext-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=gettext) [![nginx](https://img.shields.io/badge/nginx-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=nginx) [![nginx-mod-http-brotli](https://img.shields.io/badge/nginx--mod--http--brotli-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=nginx-mod-http-brotli) [![tzdata](https://img.shields.io/badge/tzdata-555?style=flat)](https://pkgs.alpinelinux.org/packages?name=tzdata)
<!-- sf:contents-apk:end -->

## Usage

Your site repo is just static assets + a two-line Dockerfile:

```dockerfile
FROM docker.io/prplanit/static-site:vX.Y.Z
COPY www-data/ /usr/share/nginx/html/
```

## Features

|                        |                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------- |
| **Non-root**           | runs as uid 10001 on port 8080 — no privileged port, no root                        |
| **Brotli + gzip**      | brotli (with `brotli_static`) preferred, gzip fallback                              |
| **Read-only friendly** | pid / temp / rendered config all live in `/tmp` → set `readOnlyRootFilesystem: true` |
| **Pinned + scanned**   | Alpine + nginx + brotli pinned to exact versions; Trivy/Grype + SBOM in CI          |
| **Configurable port**  | `LISTEN_PORT` env (default 8080), applied via envsubst at startup                    |
| **Security headers**   | `X-Content-Type-Options`, `Referrer-Policy`, `Permissions-Policy` on every response |
| **Health endpoint**    | `GET /healthz` → `200` (for k8s probes)                                             |

## Configuration

| env                | default | purpose                    |
| ------------------ | ------- | -------------------------- |
| `LISTEN_PORT`      | `8080`  | listen port                |
| `LOG_LEVEL`        | `warn`  | nginx `error_log` level    |
| `WORKER_PROCESSES` | `auto`  | nginx `worker_processes`   |

## Kubernetes securityContext

Pairs with the image's non-root design:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 10001
  runAsGroup: 10001
  seccompProfile:
    type: RuntimeDefault
containers:
  - securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
    ports:
      - containerPort: 8080
```

## License

Repository files (Dockerfile, nginx config, entrypoint): **MIT**. The built image bundles nginx (BSD-2-Clause), musl (MIT), busybox (GPL-2.0), brotli (MIT), and others under their own licenses. See [LICENSE](LICENSE).
