# Docker images

| Image | Source release |
|---|---|
| `ghcr.io/basaltproject/server` | [BasaltProject/Server](https://github.com/BasaltProject/Server/releases) |
| `ghcr.io/basaltproject/proxy` | [BasaltProject/Proxy](https://github.com/BasaltProject/Proxy/releases) |

Tags: `<version>` (for example `26.3.1`) and `latest`, which follows the latest stable release (the `nightly` prerelease is never built). Architectures: `linux/amd64` and `linux/arm64`. Both are built from the release binaries, whose SHA-256 is checked against the release `SHA256SUMS` during the build.

Base image: `debian:13.7-slim` (the binaries need glibc 2.38 or newer, plus `libatomic1`). They run as UID 10001 and keep all their state in `/data`.

## Server

```bash
docker run -d --name basalt \
  -p 25565:25565/tcp -p 19132:19132/udp \
  -v basalt-server:/data \
  -e EULA=1 \
  -i -t \
  ghcr.io/basaltproject/server:latest
```

The EULA is never accepted by default. With `EULA=1` the entrypoint starts the server with `--accept-eula`, which counts as accepting the [Minecraft EULA](https://www.minecraft.net/en-us/eula). Without it the server writes `eula.toml` in `/data` and exits with code 78; you can also set `eula = true` there. Named volumes inherit the owner of `/data` from the image. If you mount a host folder instead (`-v ./data:/data`), it must be writable by UID 10001.

## Proxy

```bash
docker run -d --name basalt-proxy \
  -p 25565:25565/tcp -p 19132:19132/udp \
  -v basalt-proxy:/data \
  -i -t \
  ghcr.io/basaltproject/proxy:latest
```

The proxy has no EULA. Publish `19132/udp` only if Bedrock is enabled. Inside a container `localhost` is the container itself, so backend hosts in `backends.toml` must be reachable from it.

## Console

With `-i -t` (`stdin_open: true` and `tty: true` in Compose) you can reach the console:

```bash
docker attach basalt
```

Detach with `Ctrl+P Ctrl+Q` (Docker default).

## Building and publishing

`.github/workflows/images.yml` runs every hour, on pushes to `main` that touch `docker/**` or the workflow, and manually. The scheduled run only builds a version whose tag is missing in GHCR; the other two always rebuild. To run it by hand: Actions > Images > Run workflow (optionally a `version`, which also never moves `latest` unless it is the latest release), or:

```bash
gh workflow run images.yml -f version=26.3.1
```

Local build (single architecture):

```bash
docker build --build-arg VERSION=26.3.1 -t basalt-server docker/server
```
