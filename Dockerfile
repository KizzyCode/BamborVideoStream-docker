# Build the daemon
FROM debian:latest AS buildenv

ENV APT_PACKAGES build-essential ca-certificates curl git libssl-dev pkg-config
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES}

RUN curl --tlsv1.3 --output rustup.sh https://sh.rustup.rs \
    && sh rustup.sh -y

RUN git clone https://github.com/KizzyCode/BamborVideoStream-rust \
    && /root/.cargo/bin/cargo install --path BamborVideoStream-rust --bins bamborvideostream


# Build the real container
FROM debian:latest

ENV APT_PACKAGES libssl3
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
    && apt-get upgrade --yes \
    && apt-get install --yes --no-install-recommends ${APT_PACKAGES}
COPY --from=buildenv /root/.cargo/bin/bamborvideostream /usr/bin/

RUN adduser --system --shell=/bin/nologin --uid=1000 bamborvideostream
USER bamborvideostream
CMD ["/usr/bin/bamborvideostream"]
