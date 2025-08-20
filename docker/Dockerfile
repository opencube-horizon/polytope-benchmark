FROM eccr.ecmwf.int/opencube/openfam:3.0.0
ARG TARGETARCH

RUN apt update \
    && apt install -y wget gpg openssl python3 python3-pip cmake git gcc gfortran python3.11-dev python3-scipy python3-fiona 

SHELL ["/bin/bash", "-c"]

RUN mkdir -p -m 0600 /root/.ssh \
    && ssh-keyscan git.ecmwf.int >> /root/.ssh/known_hosts \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && cat /root/.ssh/known_hosts

# Install bundle 
WORKDIR /home
RUN --mount=type=ssh git clone ssh://git@git.ecmwf.int/~mawj/polytope-bundle.git -v --branch opencube/fdb-fam --single-branch --depth 1 \
    && cat /home/polytope-bundle/bundle.yml 
RUN --mount=type=ssh cd /home/polytope-bundle \
    && bash polytope-bundle create \
    && bash polytope-bundle build \
    && build/install.sh --fast \
    && cd ..

ENV LD_LIBRARY_PATH=/home/polytope-bundle/install/lib:$LD_LIBRARY_PATH

COPY requirements.txt /home/requirements.txt
RUN apt install -y python3-venv \
    && python3 -m venv --system-site-packages /home/env \
    && source /home/env/bin/activate \
    && python -m pip install pip --upgrade \    
    && python -m pip install -r /home/requirements.txt \
    && python -m pip list 

COPY run-benchmark.py /home/run-benchmark.py
COPY test_data /home/test_data
COPY templates /home/fdb/etc/fdb
COPY run.sh /home/run.sh
ENV FDB_HOME=/home/fdb

ENTRYPOINT [ "bash", "run.sh"]
