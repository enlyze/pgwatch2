FROM golang

WORKDIR /src
COPY . /src/

RUN set -eux \
 && cd /src \
 && ./build_gatherer.sh

FROM golang

WORKDIR /pgwatch2
COPY metrics /pgwatch2/metrics

COPY --from=0 /pgwatch2/pgwatch2 /usr/local/bin/

ENTRYPOINT [ "pgwatch2", "--metrics-folder=/pgwatch2/metrics" ]
