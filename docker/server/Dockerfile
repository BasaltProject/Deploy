# syntax=docker/dockerfile:1

# Download stage: runs on the build host's own architecture and only fetches
# and verifies the right binary for the target, so no emulation is needed.
FROM --platform=$BUILDPLATFORM debian:13.7-slim AS download
ARG TARGETARCH
ARG VERSION
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /dl
RUN set -eu; \
    test -n "${VERSION}"; \
    case "${TARGETARCH}" in \
      amd64) ARCH=x64 ;; \
      arm64) ARCH=arm64 ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    ASSET="BasaltServer-${VERSION}-Linux-${ARCH}"; \
    BASE="https://github.com/BasaltProject/Server/releases/download/v${VERSION}"; \
    curl -fsSL --retry 3 -o "${ASSET}" "${BASE}/${ASSET}"; \
    curl -fsSL --retry 3 -o SHA256SUMS "${BASE}/SHA256SUMS"; \
    grep -F " ${ASSET}" SHA256SUMS | grep -E " \*?${ASSET}$" > check.txt; \
    test "$(wc -l < check.txt)" -eq 1; \
    sha256sum -c check.txt; \
    mv "${ASSET}" basalt

# Final stage
FROM debian:13.7-slim
ARG VERSION
LABEL org.opencontainers.image.title="Basalt Server" \
      org.opencontainers.image.description="Official Basalt Server image" \
      org.opencontainers.image.source="https://github.com/BasaltProject/Server" \
      org.opencontainers.image.url="https://github.com/BasaltProject/Deploy" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.licenses="GPL-3.0"
# libatomic1 is a dynamic dependency of the binary (not in the slim base).
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates libatomic1 \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --uid 10001 --user-group --no-create-home --home-dir /data basalt \
 && mkdir /data && chown basalt:basalt /data
COPY --from=download --chmod=0755 /dl/basalt /usr/local/bin/basalt
COPY --chmod=0755 entrypoint.sh /usr/local/bin/entrypoint.sh
USER 10001:10001
WORKDIR /data
VOLUME /data
EXPOSE 25565/tcp 19132/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
