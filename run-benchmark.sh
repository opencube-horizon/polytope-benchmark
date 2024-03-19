#!/bin/bash
set -e

OUTPUT_DIR=bench_run
NAME=polytope
IMAGE=ghcr.io/opencube-horizon/polytope-benchmark@sha256:3fe20ca20bc8b583e2ccb0af847677197a2c399c05e3f7752a7a6bd9cc73976e
SECRET=github
MEMORY="20G"

mkdir -p $OUTPUT_DIR
LATEST_RUN_NUMBER=$(ls $OUTPUT_DIR | tail -1)
NEXT_RUN_NUMBER=$(printf "%06d" "$(expr $LATEST_RUN_NUMBER + 1)")
RUN_DIR=$OUTPUT_DIR/$NEXT_RUN_NUMBER
mkdir -p $RUN_DIR

cp deployment/job.yaml job.yaml
sed -i -e "s/%NAME%/$NAME/g" job.yaml
sed -i -e "s#%IMAGE%#$IMAGE#g" job.yaml
sed -i -e "s/%SECRET%/$SECRET/g" job.yaml
sed -i -e "s/%MEMORY%/$MEMORY/g" job.yaml
kubectl create -f job.yaml
kubectl wait --for=condition=ready pod --selector=job-name=$NAME --timeout=600s
kubectl logs --follow --timestamps "job/$NAME" > $RUN_DIR/results.txt