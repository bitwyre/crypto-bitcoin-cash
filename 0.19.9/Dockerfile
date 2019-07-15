FROM debian:stable-slim

LABEL maintainer.0="Dendi Suhubdy (@dendisuhubdy)"

RUN useradd -r bitcoin \
    && apt-get update -y \
    && apt-get install -y curl gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV BITCOIN_ABC_VERSION=0.19.9
ENV BITCOIN_ABC_DATA=/home/bitcoin/.bitcoin
ENV PATH=/opt/bitcoin-abc-${BITCOIN_ABC_VERSION}/bin:$PATH

RUN curl -SLO https://download.bitcoinabc.org/${BITCOIN_ABC_VERSION}/jasonbcox-sha256sums.${BITCOIN_ABC_VERSION}.asc \
    && curl -SLO https://download.bitcoinabc.org/${BITCOIN_ABC_VERSION}/linux/bitcoin-abc-${BITCOIN_ABC_VERSION}-x86_64-linux-gnu.tar.gz \
    && grep " bitcoin-abc-${BITCOIN_ABC_VERSION}-x86_64-linux-gnu.tar.gz\$" jasonbcox-sha256sums.${BITCOIN_ABC_VERSION}.asc | sha256sum -c - \
    && tar -xzf *.tar.gz -C /opt \
    && rm *.tar.gz *.asc

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

VOLUME ["/home/bitcoin/.bitcoin"]

EXPOSE 8332 8333 18332 18333 18443 18444

ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
