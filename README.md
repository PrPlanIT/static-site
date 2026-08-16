# static-site

Hardened, non-root **nginx** (with brotli) base image for prplanit static sites. Consumer repos are two-liners — `FROM` this image and `COPY` your static assets — and inherit non-root, `readOnlyRootFilesystem`-friendly, pinned, and security-scanned defaults.

<!-- sf:project:start -->
<!-- sf:project:end -->
<!-- sf:badges:start -->
<!-- sf:badges:end -->
<!-- sf:image:start -->
<!-- sf:image:end -->

## Usage

Your site repo is just static assets + a two-line Dockerfile:

```dockerfile
FROM cr.pcfae.com/prplanit/static-site:vX.Y.Z
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
