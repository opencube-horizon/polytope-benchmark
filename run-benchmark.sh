#!/bin/bash
set -e

OUTPUT_DIR=bench_run
NAME=polytope
IMAGE=ghcr.io/opencube-horizon/polytope-benchmark@sha256:7cca2b6ebd241d2142c5f5bc09c24acdf37abd5f45e07090de716ce6a3ae5d02
SECRET=github
MEMORY="20G"

mkdir -p $OUTPUT_DIR
LATEST_RUN_NUMBER=$(ls $OUTPUT_DIR | tail -1)
NEXT_RUN_NUMBER=$(printf "%06d" "$(expr $LATEST_RUN_NUMBER + 1)")
RUN_DIR=$OUTPUT_DIR/$NEXT_RUN_NUMBER
mkdir -p $RUN_DIR

FDB_TYPE=${1:-local}
if [ $FDB_TYPE = "remote" ]; then
   HOST=${2:-"infra2"}
   PORT=${3:-"9000"}
   ARGS="[remote, $HOST, '$PORT']"
   cp deployment/job-remote.yaml job.yaml
elif [ $FDB_TYPE = "local" ]; then
   HOST_INDEX=${2:-/home/jwong/fdb/fam-local/database}
   INDEX=${3:-/home/fdb/local/data}
   FAM_URI=${4:-fam://10.115.3.2:8080/jw_data_region}
   ARGS="[local, ${INDEX}, ${FAM_URI}]"
   cp deployment/job-local.yaml job.yaml
   sed -i -e "s#%INDEX%#$INDEX#g" job.yaml
   sed -i -e "s#%HOST_INDEX%#$HOST_INDEX#g" job.yaml
fi
sed -i -e "s#%IMAGE%#$IMAGE#g" job.yaml
sed -i -e "s/%SECRET%/$SECRET/g" job.yaml
sed -i -e "s/%MEMORY%/$MEMORY/g" job.yaml
sed -i -e "s#%ARGS%#$ARGS#g" job.yaml
mv job.yaml $RUN_DIR/job.yaml

export KUBECONFIG=$(realpath /home/jwong/.kube/config)

ARCH=$(uname -m)
mkdir $RUN_DIR/jobs
for index in $(seq 1 10); 
do
  jobname=${NAME}-$index
  sed -e "s/%NAME%/$jobname/g" $RUN_DIR/job.yaml > $RUN_DIR/jobs/job_$index.yaml
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG create -f $RUN_DIR/jobs/job_$index.yaml
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG wait --for=condition=ready pod --selector=job-name=$jobname --timeout=600s
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG get pods --selector=job-name=$jobname --output=wide > $RUN_DIR/results_$index.txt
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG logs --follow --timestamps "job/$jobname" >> $RUN_DIR/results_$index.txt
done 
