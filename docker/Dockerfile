FROM harbor.pt.horizon-opencube.eu/ecmwf/fdb-fam:1.0.0 

WORKDIR /home/benchmark
RUN zypper update -y \
    && zypper install -y python311-devel gdal gdal-devel proj
ENV GDAL_VERSION=3.6.2

COPY requirements.txt /home/requirements.txt
RUN python3.11 -m venv --system-site-packages /home/env \
    && source /home/env/bin/activate \
    && python -m pip install pip --upgrade \    
    && python -m pip install -r /home/requirements.txt \
    && python -m pip list 

RUN groupadd -g 20013 ecmwf 
 
COPY run-benchmark.py /home/benchmark/run-benchmark.py
COPY test_data /home/benchmark/test_data
COPY templates/remote-config.yaml /home/benchmark/fdb/remote/etc/fdb/config.yaml
COPY templates/local-config.yaml /home/benchmark/fdb/local/etc/fdb/config.yaml
COPY templates/schema /home/benchmark/fdb/local/etc/fdb/schema
COPY run.sh /home/benchmark/run.sh
RUN sed -i "s;%SCHEMA%;/home/benchmark/fdb/local/etc/fdb/schema;g" /home/benchmark/fdb/local/etc/fdb/config.yaml
RUN chgrp --recursive ecmwf /home/benchmark && chmod --recursive g=u /home/benchmark

RUN useradd -M -d /home/benchmark -u 1234 -g 20013 benchuser
USER benchuser
ENV USER=benchuser
ENV HOME=/home/benchmark
WORKDIR /home/benchmark

ENV FINDLIBS_DISABLE_PACKAGE=yes
ENTRYPOINT [ "bash", "/home/benchmark/run.sh"]
