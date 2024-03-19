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


RUN git clone --depth 1 --branch 2.33.0 https://github.com/ecmwf/eccodes.git \
    && git clone --depth 1 --branch 3.8.2 https://github.com/ecmwf/ecbuild.git \
    && export PATH=$PWD/ecbuild/bin:$PATH \
    && mkdir build \
    && cd build \
    && cmake  ../eccodes -DCMAKE_INSTALL_PREFIX=/eccodes_installation -DENABLE_AEC=OFF \
    && make \
    && make install \ 
    && cd .. 

RUN source /root/miniforge3/bin/activate \
    && conda install -y gdal 

RUN export GDAL_CONFIG=/root/miniforge3/bin/gdal-config \
    && python3 -m pip install pip --upgrade --break-system-packages \    
    && python3 -m pip install --break-system-packages cfgrib==0.9.10.3 \
    Shapely \
    shp==1.0.2 \
    Fiona==1.8.22 \
    geopandas==0.10.2 \
    pyshp==2.3.1 \
    importlib-metadata==4.13.0 \
    decorator==5.1.1 \
    pandas==1.3.5 \
    pypi==2.1 \
    requests==2.28.1 \
    sortedcontainers==2.4.0 \
    tripy==1.0.0 \
    typing==3.7.4.3 \
    xarray==0.20.2 \
    pytest==7.2.0 \
    cffi==1.15.1 \
    eccodes==1.5.2 \
    h5netcdf==1.1.0 \
    h5py==3.8.0

RUN git clone --single-branch --branch develop https://github.com/ecmwf/polytope.git\
    && cd polytope \
    && git checkout d21c190 \
    && python3 -m pip install --break-system-packages -e .

WORKDIR /home
COPY run-benchmark.py /home/run-benchmark.py

COPY test_data /home/test_data

ENTRYPOINT [ "python3" , "/home/run-benchmark.py"]
