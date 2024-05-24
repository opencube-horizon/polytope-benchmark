FROM debian:bookworm
ARG TARGETARCH

RUN apt update \
    && apt install -y wget gpg openssl python3 python3-pip cmake git gcc gfortran python3.11-dev python3-ecmwflibs python3-scipy python3-fiona 

SHELL ["/bin/bash", "-c"]

RUN mkdir -p -m 0600 /root/.ssh \
    && ssh-keyscan git.ecmwf.int >> /root/.ssh/known_hosts \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && cat /root/.ssh/known_hosts

# Install bundle 
WORKDIR /home
RUN --mount=type=ssh git clone ssh://git@git.ecmwf.int/~mawj/polytope-bundle.git -v --branch main --single-branch --depth 1 
RUN --mount=type=ssh cd /home/polytope-bundle \
    && bash polytope-bundle create \
    && bash polytope-bundle build \
    && build/install.sh --fast \
    && cd ..

ENV LD_LIBRARY_PATH=/home/polytope-bundle/install/lib:$LD_LIBRARY_PATH

COPY requirements.txt /home/requirements.txt
RUN python3 -m pip install pip --upgrade --break-system-packages \    
    && python3 -m pip install --break-system-packages -r /home/requirements.txt

COPY run-benchmark.py /home/run-benchmark.py
COPY test_data /home/test_data
COPY templates /home/fdb/etc/fdb
COPY run.sh /home/run.sh
ENV FDB_HOME=/home/fdb

ENTRYPOINT [ "bash", "run.sh"]
