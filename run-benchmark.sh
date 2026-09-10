#!/bin/bash
set -e

OUTPUT_DIR=bench_run
NAME=polytope
IMAGE=ghcr.io/opencube-horizon/polytope-benchmark@sha256:a95d0cddab768ac56ad82cfef1c43ca561f124164079722bedff802c832fce9c
SECRET=pproc-secret
NAMESPACE=openfam
MEMORY="20G"
NODE_LIST="[cn05, cn06, cn07]"

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
   FAM_URI=${4:-fam://10.42.4.208:8080/pproc_test_region}
   ARGS="[local, ${FAM_URI}]"
   cp deployment/job-local.yaml job.yaml
fi
sed -i -e "s#%IMAGE%#$IMAGE#g" job.yaml
sed -i -e "s/%SECRET%/$SECRET/g" job.yaml
sed -i -e "s/%MEMORY%/$MEMORY/g" job.yaml
sed -i -e "s#%ARGS%#$ARGS#g" job.yaml
sed -i -e "s/%NODE_LIST%/$NODE_LIST/g" job.yaml
mv job.yaml $RUN_DIR/job.yaml

export KUBECONFIG=$(realpath /home/jwong/.kube/config)

ARCH=$(uname -m)
mkdir $RUN_DIR/jobs
for index in $(seq 1 10); 
do
  jobname=${NAME}-$index
  sed -e "s/%NAME%/$jobname/g" $RUN_DIR/job.yaml > $RUN_DIR/jobs/job_$index.yaml
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG create -n $NAMESPACE -f $RUN_DIR/jobs/job_$index.yaml
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG wait -n $NAMESPACE --for=condition=ready pod --selector=job-name=$jobname --timeout=600s
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG get -n $NAMESPACE pods --selector=job-name=$jobname --output=wide > $RUN_DIR/results_$index.txt
  ~/bin/$ARCH/kubectl --kubeconfig=$KUBECONFIG logs -n $NAMESPACE --follow --timestamps "job/$jobname" >> $RUN_DIR/results_$index.txt
done 
