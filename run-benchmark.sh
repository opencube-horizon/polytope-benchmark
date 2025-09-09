#!/bin/bash
set -e

OUTPUT_DIR=bench_run
NAME=polytope
IMAGE=ghcr.io/opencube-horizon/polytope-benchmark@sha256:ca1729bc2e0ec5c073bb051724e789f2abaa53e6c554ba647775f39d12e191fd 
SECRET=github
MEMORY="20G"
HOST=${FDB_HOST:-infra1}
PORT=${FDB_PORT:-9000}
ARGS="[$HOST, $PORT, 'fdb:', 'fdb:', 'fdb:']"

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
sed -i -e "s/%ARGS%/$ARGS/g" job.yamli
cp job.yaml $RUN_DIR

export KUBECONFIG=$(realpath /home/jwong/.kube/config)

ARCH=$(uname -m)
~/bin/$ARCH/kubectl create -f job.yaml
~/bin/$ARCH/kubectl wait --for=condition=ready pod --selector=job-name=$NAME --timeout=600s
~/bin/$ARCH/kubectl logs --follow --timestamps "job/$NAME" > $RUN_DIR/results.txt
