#!/bin/bash

FDB_TYPE=${1}

# Set up FDB config
if [ "$FDB_TYPE" = "remote" ]; then 
    export FDB_HOME=/home/fdb/remote
    HOST=${2}
    PORT=${3}
    echo "ARGS:" $FDB_TYPE $HOST $PORT
    sed -i "s/%HOST%/$HOST/g" ${FDB_HOME}/etc/fdb/config.yaml
    sed -i "s/%PORT%/$PORT/g" ${FDB_HOME}/etc/fdb/config.yaml
elif [ "$FDB_TYPE" = "local" ]; then 
    export FDB_HOME=/home/fdb/local
    INDEX=${2}
    FAM_URI=${3}
    echo "ARGS:" $FDB_TYPE $INDEX $FAM_URI
    sed -i "s;%INDEX%;$INDEX;g" ${FDB_HOME}/etc/fdb/config.yaml
    sed -i "s;%FAM_URI%;${FAM_URI};g" ${FDB_HOME}/etc/fdb/config.yaml
else
    echo "Unknown FDB type $FDB_TYPE"
    exit 1
fi

cat ${FDB_HOME}/etc/fdb/config.yaml
source /home/env/bin/activate
python /home/run-benchmark.py --polygon-source fdb: --vertical-source fdb: --timeseries-source fdb:
