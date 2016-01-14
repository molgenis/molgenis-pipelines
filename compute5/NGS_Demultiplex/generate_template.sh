#!/bin/bash

##external call with 2 arguments (sequencer and run)

module load NGS_Demultiplex
module list

ENVIRONMENT_PARAMETERS=parameters_zinc-finger.csv
TMPDIR=tmp05
WORKDIR="/groups/umcg-gaf/${TMPDIR}"
SEQUENCER=$1
RUNNUMBER=${2}_${SEQUENCER}
WORKFLOW=${EBROOTNGS_DEMULTIPLEX}/workflow.csv

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/

if [ -f ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv  ];
then
    	rm -rf ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv
fi

perl ${EBROOTNGS_DEMULTIPLEX}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEX}/parameters.csv > \
${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv

perl ${EBROOTNGS_DEMULTIPLEX}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEX}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/run_${RUNNUMBER}/environment_parameters.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/environment_parameters.csv \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/run_${RUNNUMBER}.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/runs/run_${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate
