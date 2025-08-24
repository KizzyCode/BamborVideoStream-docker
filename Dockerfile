# Build the daemon
FROM debian:stable-slim AS buildenv

ENV APT_PACKAGES build-essential ca-certificates curl git libssl-dev pkg-config
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES}

RUN useradd --system --uid=10000 rust
USER rust
WORKDIR /home/rust/

RUN curl --tlsv1.3 --output rustup.sh https://sh.rustup.rs \
    && sh rustup.sh -y --profile minimal
RUN git clone https://github.com/KizzyCode/BamborVideoStream-rust \
    && .cargo/bin/cargo install --path BamborVideoStream-rust --bins bamborvideostream


# Build the real container
FROM debian:stable-slim

ENV APT_PACKAGES libssl3
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES}
COPY --from=buildenv --chown=root:root /home/rust/.cargo/bin/bamborvideostream /usr/bin/

RUN useradd --system --shell=/bin/nologin --uid=10000 bamborvideostream
USER bamborvideostream
ENTRYPOINT ["/usr/bin/bamborvideostream"]
