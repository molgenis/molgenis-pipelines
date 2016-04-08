#!/bin/bash

##Choose parameters_calculon or parameters_zinc-finger
ENVIRONMENT_PARAMETERS=parameters_zinc-finger.csv
PROJECT=$1
TMPDIR=$2
WORKDIR="/groups/umcg-gaf/${TMPDIR}"
RUNID=run01
## For small batchsize (6) leave BATCH empty, _exome (10 batches) or _wgs (20 batches)  OR  this is beta: _chr (per chrosomome), _NO (1 batch),
BATCH="_chr"
THISDIR=$(pwd)

SAMPLESIZE=$(( $(sh ${EBROOTNGS_DNA}/samplesize.sh ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv $THISDIR) -1 ))
echo "Samplesize is $SAMPLESIZE"
if [ $SAMPLESIZE -gt 199 ]
then
    	WORKFLOW=${EBROOTNGS_DNA}/workflow_samplesize_bigger_than_200.csv
else
        WORKFLOW=${EBROOTNGS_DNA}/workflow.csv
fi

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${WORKDIR}/generatedscripts/${PROJECT}/out.csv  ];
then
    	rm -rf ${WORKDIR}/generatedscripts/${PROJECT}/out.csv
fi

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/out.csv


perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv
module list
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/out.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv \
-p ${EBROOTNGS_DNA}/batchIDList${BATCH}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_DNA}/automated_create_in-house_ngs_projects_workflow.csv \
-rundir ${WORKDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${WORKFLOW};\
outputdir=scripts/jobs;mainParameters=${WORKDIR}/generatedscripts/${PROJECT}/out.csv;\
ngsversion=$(module list | grep -o -P 'NGS_DNA(.+)');\
environment_parameters=${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv;\
batchIDList=${EBROOTNGS_DNA}/batchIDList${BATCH}.csv;\
worksheet=${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate

