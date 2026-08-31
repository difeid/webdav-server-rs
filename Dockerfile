FROM rust:1.98.0-slim-trixie AS build

RUN apt-get update && apt-get install -y \
    build-essential \
    libpam0g-dev \
    libtirpc-dev \
    pkg-config

WORKDIR /usr/src/webdav-server
COPY ./ ./

RUN cargo build --locked --release && cargo install --path .

FROM debian:trixie-slim
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    libpam0g \
    libtirpc3 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/cargo/bin/webdav-server /usr/local/bin/
COPY webdav-server.toml /config/

LABEL org.opencontainers.image.url="https://github.com/difeid/webdav-server-rs" \
      org.opencontainers.image.title="WebDAV server" \
      org.opencontainers.image.version="0.5.4" \
      org.opencontainers.image.licenses="Apache-2.0"

CMD ["webdav-server", "-c", "/config/webdav-server.toml"]
