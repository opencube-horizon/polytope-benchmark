FROM harbor.pt.horizon-opencube.eu/ecmwf/pproc-fdb-fam:0.0.1 

WORKDIR /home/benchmark
RUN zypper update -y \
    && zypper install -y gdal gdal-devel proj libffi-devel
ENV GDAL_VERSION=3.6.2

RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/bin" sh && uv --version
ENV UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python
ENV UV_PYTHON_BIN_DIR=/usr/local/bin
COPY requirements.txt /home/requirements.txt
RUN export CC=gcc-15 \
    && export CXX=g++-15 \
    && export CFLAGS='-Wno-error=incompatible-pointer-types' \
    && export ECCODES_PYTHON_USE_FINDLIBS=1 \
    && export FINDLIBS_DISABLE_PACKAGE=yes \
    && uv venv --python 3.12 --seed /home/env \
    && source /home/env/bin/activate \
    && python -m pip install pip --upgrade \    
    && python -m pip install -r /home/requirements.txt \
    && python -m pip list 

 
COPY run-benchmark.py /home/benchmark/run-benchmark.py
COPY test_data /home/benchmark/test_data
COPY templates/remote-config.yaml /home/benchmark/fdb/remote/etc/fdb/config.yaml
COPY templates/local-config.yaml /home/benchmark/fdb/local/etc/fdb/config.yaml
COPY templates/fam-schema /home/benchmark/fdb/local/etc/fdb/schema
COPY run.sh /home/benchmark/run.sh
RUN sed -i "s;%SCHEMA%;/home/benchmark/fdb/local/etc/fdb/schema;g" /home/benchmark/fdb/local/etc/fdb/config.yaml

ENV HOME=/home/benchmark
WORKDIR /home/benchmark

ENV FINDLIBS_DISABLE_PACKAGE=yes
ENTRYPOINT [ "bash", "/home/benchmark/run.sh"]
