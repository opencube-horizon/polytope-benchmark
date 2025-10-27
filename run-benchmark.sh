#!/bin/bash
set -e

OUTPUT_DIR=bench_run
NAME=polytope
IMAGE=ghcr.io/opencube-horizon/polytope-benchmark@sha256:fc07253abddcabcfc59b2a1f85ab2f82841cd12bf963626ca7ba1b8f296de2d9
SECRET=github
MEMORY="20G"

mkdir -p $OUTPUT_DIR
LATEST_RUN_NUMBER=$(ls $OUTPUT_DIR | tail -1)
NEXT_RUN_NUMBER=$(printf "%06d" "$(expr $LATEST_RUN_NUMBER + 1)")
RUN_DIR=$OUTPUT_DIR/$NEXT_RUN_NUMBER
mkdir -p $RUN_DIR

FDB_TYPE=${1:-local}
if [ $FDB_TYPE = "remote" ]; then
   HOST=${2:-"infra1"}
   PORT=${3:-"9000"}
   ARGS="[remote, $HOST, '$PORT']"
   cp deployment/job-remote.yaml job.yaml
elif [ $FDB_TYPE = "local" ]; then
   HOST_INDEX=${2:-/home/jwong/fdb/fam-local/database}
   INDEX=${3:-/home/fdb/local/data}
   FAM_URI=${4:-fam://10.115.3.1:8780/jw_region}
   ARGS="[local, ${INDEX}, ${FAM_URI}]"
   cp deployment/job-local.yaml job.yaml
   sed -i -e "s#%INDEX%#$INDEX#g" job.yaml
   sed -i -e "s#%HOST_INDEX%#$HOST_INDEX#g" job.yaml
fi
sed -i -e "s/%NAME%/$NAME/g" job.yaml
sed -i -e "s#%IMAGE%#$IMAGE#g" job.yaml
sed -i -e "s/%SECRET%/$SECRET/g" job.yaml
sed -i -e "s/%MEMORY%/$MEMORY/g" job.yaml
sed -i -e "s#%ARGS%#$ARGS#g" job.yaml
mv job.yaml $RUN_DIR/job.yaml

export KUBECONFIG=$(realpath /home/jwong/.kube/config)

ARCH=$(uname -m)
~/bin/$ARCH/kubectl create -f $RUN_DIR/job.yaml
~/bin/$ARCH/kubectl wait --for=condition=ready pod --selector=job-name=$NAME --timeout=600s
~/bin/$ARCH/kubectl logs --follow --timestamps "job/$NAME" > $RUN_DIR/results.txt
