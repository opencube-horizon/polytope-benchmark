FROM debian:buster

RUN apt update \
    && apt install -y curl gpg openssl python3 python3-pip cmake git gcc gfortran python3.7-dev 

# Install conda
RUN curl https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc | gpg --dearmor > conda.gpg \
    && install -o root -g root -m 644 conda.gpg /usr/share/keyrings/conda-archive-keyring.gpg \ 
    && gpg --keyring /usr/share/keyrings/conda-archive-keyring.gpg --no-default-keyring --fingerprint 34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806 \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/conda-archive-keyring.gpg] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main" > /etc/apt/sources.list.d/conda.list \
    && apt update \
    && apt install -y conda

RUN git clone https://github.com/ecmwf/eccodes.git \
    && git clone https://github.com/ecmwf/ecbuild.git \
    && export PATH=$PWD/ecbuild/bin:$PATH \
    && mkdir build \
    && cd build \
    && cmake  ../eccodes -DCMAKE_INSTALL_PREFIX=/eccodes_installation -DENABLE_AEC=OFF \
    && make \
    && ctest \
    && make install \ 
    && cd .. 

SHELL ["/bin/bash", "-c"]

RUN source /opt/conda/etc/profile.d/conda.sh \
    && conda -V \
    && conda install -y gdal \
    && export GDAL_CONFIG=/opt/conda/bin/gdal-config 

RUN pip3 install --upgrade pip \
    && pip3 install cfgrib==0.9.10.3 \
    Shapely \
    shp==1.0.2 \
    Fiona==1.8.22 \
    geopandas==0.10.2 \
    pyshp==2.3.1 \
    ecmwflibs \
    importlib-metadata==4.13.0 \
    decorator==5.1.1 \
    numpy==1.21.6 \
    pandas==1.3.5 \
    pypi==2.1 \
    requests==2.28.1 \
    scipy==1.7.3 \
    sortedcontainers==2.4.0 \
    tripy==1.0.0 \
    typing==3.7.4.3 \
    xarray==0.20.2 \
    pytest==7.2.0 \
    cffi==1.15.1 \
    eccodes==1.5.2 \
    h5netcdf==1.1.0 \
    h5py==3.8.0

RUN git clone https://github.com/ecmwf/polytope.git \
    && cd polytope \
    && pip3 install -e .

WORKDIR /home
COPY run-benchmark.py /home/run-benchmark.py

ENTRYPOINT [ "python3" , "/home/run-benchmark.py"]