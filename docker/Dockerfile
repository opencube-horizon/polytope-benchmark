FROM eccr.ecmwf.int/opencube/fdb-fam-devos:latest 

WORKDIR /home
RUN zypper update -y \
    && zypper install -y python311-devel gdal gdal-devel proj
ENV GDAL_VERSION=3.6.2

COPY requirements.txt /home/requirements.txt
RUN python3.11 -m venv --system-site-packages /home/env \
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
COPY run.sh /home/run.sh

ENV FINDLIBS_DISABLE_PACKAGE=yes

ENTRYPOINT [ "bash", "/home/run.sh"]
