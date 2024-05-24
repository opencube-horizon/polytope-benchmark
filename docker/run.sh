#!/bin/bash

HOST=${1:-localhost}
PORT=${2:-8080}
POLYGON_SOURCE=${3:-"file:test_data/polygon.grib"}
VERTICAL_SOURCE=${4:-"file:test_data/vertical.grib"}
TIMESERIES_SOURCE=${5:-"file:test_data/timeseries.grib"}

echo "ARGS:" $HOST $PORT $POLYGON_SOURCE $VERTICAL_SOURCE $TIMESERIES_SOURCE

# Set up FDB config
sed -i "s/%HOST%/$HOST/g" /home/fdb/etc/fdb/config.yaml
sed -i "s/%PORT%/$PORT/g" /home/fdb/etc/fdb/config.yaml

python3 run-benchmark.py --polygon-source $POLYGON_SOURCE --vertical-source $VERTICAL_SOURCE --timeseries-source $TIMESERIES_SOURCE
