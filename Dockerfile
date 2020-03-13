# Stage 1 - Build

FROM gcc:8 as builder

COPY bitcoin-abc /app/src/bitcoin-abc
WORKDIR /app/src/bitcoin-abc

ENV NO_QT=1

RUN apt-get update && apt-get install -y bsdmainutils
RUN echo "\nSubmodule files:"&& \
    ls -Falg --group-directories-first && \
    echo && \
    gcc --version && \
    cd depends && \
    mkdir x86_64-pc-linux-gnu && \
    make -j8
RUN ./autogen.sh && \
    ./configure LDFLAGS="-static-libstdc++" --prefix="/app/src/bitcoin-abc/depends/x86_64-pc-linux-gnu" \
    --without-miniupnpc --enable-hardening --with-zmq --disable-man --disable-shared \
    --disable-bench --disable-test --without-gui --enable-cxx
RUN make install -j8
RUN cd /app/src/bitcoin-abc/depends/x86_64-pc-linux-gnu && \
    ls -Falg --group-directories-first && \
    strip bin/bitcoind && \
    strip bin/bitcoin-cli && \
    strip bin/bitcoin-tx && \
    strip bin/bitcoin-seeder && \
    strip lib/libbitcoinconsensus.a


# Stage 2 - Production Image

FROM ubuntu:18.04

LABEL maintainer "Yefta Sutanto <yefta@bitwyre.com>, Aditya Kresna <kresna@bitwyre.com>"

RUN apt-get update && \
    apt-get install -y --no-install-recommends gosu && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin
RUN mkdir -p /home/bitcoin-abc/.bitcoin && \
    chown -R bitcoin:bitcoin /home/bitcoin-abc

COPY --from=builder /app/src/bitcoin-abc/depends/x86_64-pc-linux-gnu /usr/local
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

VOLUME ["/home/bitcoin-abc/.bitcoin"]
EXPOSE 8332 8333 18332 18333 18443 18444 28332 28333 28334 28335

ENV BITCOIN_ABC_DATA "/home/bitcoin-abc/.bitcoin"

ENTRYPOINT [ "/./docker-entrypoint.sh" ]
CMD ["bitcoind"]
