FROM rocker/r2u:22.04

ADD src /usr/src/local/src
RUN chmod 777 /usr/src/local/src/setup.sh && \
    ./usr/src/local/src/setup.sh          && \
    rm -rf /usr/src/local/src
