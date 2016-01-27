#!/bin/bash

umask 0007

### Change at least for every different run the $project and $runid ####
project="<ProjectNameVar>"
runId='run01'
cluster="<GccClusterVar>"
niptVersion='v3.0.2-Molgenis-Compute-v15.11.1-Java-1.8.0_45'
ENVIRONMENT_PARAMETERS="parameters_${cluster}.csv"
TMPDIR=$(ls -1 /groups/umcg-gd/ |grep tmp)
WORKDIR="/groups/umcg-gd/${TMPDIR}"

module load NIPT/${niptVersion}
module list

WORKFLOW=${EBROOTNIPT}/workflow.csv

if [ -f .compute.properties ]; then
    rm .compute.properties
fi

if [ ! -f ${WORKDIR}/generatedscripts/${project} ]; then
    mkdir -m 770 -p ${WORKDIR}/generatedscripts/${project}/
fi

if [ -f ${WORKDIR}/generatedscripts/${project}/out.csv ]; then
    rm -rf ${WORKDIR}/generatedscripts/${project}/out.csv
fi

##convert human-readable-parameters file to compute-format-parameters file
perl ${EBROOTNIPT}/convertParametersGitToMolgenis.pl ${EBROOTNIPT}/parameters.csv > \
${WORKDIR}/generatedscripts/${project}/out.csv

##convert human-readable-env-parameters file to compute-format-env-parameters file
perl ${EBROOTNIPT}/convertParametersGitToMolgenis.pl ${EBROOTNIPT}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/${project}/environment_parameters.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${project}/out.csv \
-p ${WORKDIR}/generatedscripts/${project}/environment_parameters.csv \
-p ${WORKDIR}/generatedscripts/${project}/${project}.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/projects/${project}/${runId}/jobs \
-b slurm \
-runid ${runId} \
-weave \
--generate

cd ${WORKDIR}/projects/${project}/${runId}/jobs/
sh submit.sh > submit.log

echo "scripts generated, now starting the pipeline (type squeue -u USERNAME to check status of running jobs"
