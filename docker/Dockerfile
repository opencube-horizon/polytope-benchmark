FROM debian:bookworm
ARG TARGETARCH

RUN apt update \
    && apt install -y wget gpg openssl python3 python3-pip cmake git gcc gfortran python3.11-dev python3-ecmwflibs python3-scipy 

SHELL ["/bin/bash", "-c"]

# Install conda
RUN if [ "${TARGETARCH}" = "amd64" ]; then version="x86_64"; elif [ "${TARGETARCH}" = "arm64" ]; then version="aarch64"; else echo "Unsupported arch ${TARGETARCH}" && [ 1 = 0 ]; fi \
	&& wget -O miniforge.sh https://github.com/conda-forge/miniforge/releases/download/23.10.0-0/Miniforge3-23.10.0-0-Linux-${version}.sh \
    && bash miniforge.sh -b \
	&& source /root/miniforge3/bin/activate \
	&& conda -V \
	&& conda deactivate 

RUN mkdir -p -m 0600 /root/.ssh \
    && ssh-keyscan git.ecmwf.int >> /root/.ssh/known_hosts \
    && ssh-keyscan github.com >> /root/.ssh/known_hosts \
    && cat /root/.ssh/known_hosts

# Install bundle 
WORKDIR /home
RUN --mount=type=ssh git clone ssh://git@git.ecmwf.int/~mawj/polytope-bundle.git -v --branch main --single-branch --depth 1 
RUN --mount=type=ssh cd /home/polytope-bundle \
    && ./polytope-bundle create \
    && ./polytope-bundle build \
    && build/install.sh --fast \
    && cd ..

ENV LD_LIBRARY_PATH=/home/polytope-bundle/install/lib:$LD_LIBRARY_PATH

RUN source /root/miniforge3/bin/activate \
    && conda install -y gdal 

COPY requirements.txt /home/requirements.txt
RUN export GDAL_CONFIG=/root/miniforge3/bin/gdal-config \
    && python3 -m pip install pip --upgrade --break-system-packages \    
    && python3 -m pip install --break-system-packages -r /home/requirements.txt

COPY run-benchmark.py /home/run-benchmark.py
COPY test_data /home/test_data
COPY templates /home/fdb/etc/fdb
COPY run.sh /home/run.sh
ENV FDB_HOME=/home/fdb

ENTRYPOINT [ "bash", "-c", "/home/run.sh"]
