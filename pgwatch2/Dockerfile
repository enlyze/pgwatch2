FROM cybertec/pgwatch2-daemon:1.7.2

WORKDIR /pgwatch2
COPY metrics /pgwatch2/metrics

ENTRYPOINT [ "/pgwatch2/pgwatch2", "--metrics-folder=/pgwatch2/metrics" ]
