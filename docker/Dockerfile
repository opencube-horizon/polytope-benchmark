FROM --platform=$BUILDPLATFORM eccr.ecmwf.int/opencube/fdb-fam-devos:latest as builder

FROM debian:bookworm
ARG TARGETARCH

RUN rm -r /usr/local
COPY --from=builder /usr/local /usr/local

RUN apt update \
    && apt install -y wget gpg openssl python3 python3-pip cmake git gcc gfortran python3.11-dev python3-scipy python3-fiona 

SHELL ["/bin/bash", "-c"]

ENV LD_LIBRARY_PATH=/usr/local/lib64:$LD_LIBRARY_PATH

COPY requirements.txt /home/requirements.txt
RUN apt install -y python3-venv \
    && python3 -m venv --system-site-packages /home/env \
    && source /home/env/bin/activate \
    && python -m pip install pip --upgrade \    
    && python -m pip install -r /home/requirements.txt \
    && python -m pip list 

COPY run-benchmark.py /home/run-benchmark.py
COPY test_data /home/test_data
COPY templates/remote-config.yaml /home/fdb/remote/etc/fdb/config.yaml
COPY templates/local-config.yaml /home/fdb/local/etc/fdb/config.yaml
COPY templates/schema /home/fdb/local/etc/fdb/schema
RUN sed -i "s;%SCHEMA%;/home/fdb/local/etc/fdb/schema;g" /home/fdb/local/etc/fdb/config.yaml
WORKDIR /home
COPY run.sh /home/run.sh

ENTRYPOINT [ "bash", "/home/run.sh"]
