#!/bin/bash

FDB_TYPE=${1}
POLYGON_SOURCE=${2:-"file:test_data/polygon.grib"}
VERTICAL_SOURCE=${3:-"file:test_data/vertical.grib"}
TIMESERIES_SOURCE=${4:-"file:test_data/timeseries.grib"}

echo "ARGS:" $HOST $PORT $POLYGON_SOURCE $VERTICAL_SOURCE $TIMESERIES_SOURCE

# Set up FDB config
if [ $FDB_TYPE -eq "remote" ]; then 
    export FDB_HOME=/home/fdb/remote
    sed -i "s/%HOST%/$HOST/g" ${FDB_HOME}/etc/fdb/config.yaml
    sed -i "s/%PORT%/$PORT/g" ${FDB_HOME}/etc/fdb/config.yaml
elif [ $FDB_TYPE -eq "local" ]; then 
    export FDB_HOME=/home/fdb/local
    sed -i "s;%INDEX%;$INDEX;g" ${FDB_HOME}/etc/fdb/config.yaml
    sed -i "s;%FAM_URI%;$FAM_URI;g" ${FDB_HOME}/etc/fdb/config.yaml
else
    echo "Unknown FDB type $FDB_TYPE"
    exit 1
fi

source /home/env/bin/activate
python run-benchmark.py --polygon-source $POLYGON_SOURCE --vertical-source $VERTICAL_SOURCE --timeseries-source $TIMESERIES_SOURCE
