#!/bin/bash
set -e

OUTPUT_DIR=bench_run
IMAGE=eccr.ecmwf.int/opencube/polytope:v1

mkdir -p $OUTPUT_DIR
LATEST_RUN_NUMBER=$(ls $OUTPUT_DIR | tail -1)
NEXT_RUN_NUMBER=$(printf "%06d" "$(expr $LATEST_RUN_NUMBER + 1)")
RUN_DIR=$OUTPUT_DIR/$NEXT_RUN_NUMBER
mkdir -p $RUN_DIR

kubectl run polytope --image $IMAGE --overrides='{"spec": {"imagePullSecrets": [{"name": "ecmwfeccr"}] } }'
stern polytope > $RUN_DIR/results.txt