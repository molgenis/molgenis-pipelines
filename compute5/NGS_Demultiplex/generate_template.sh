#!/bin/bash

##external call with 3 arguments (sequencer, run and workDir)

module list

ENVIRONMENT_PARAMETERS=parameters_gattaca.csv
SEQUENCER=$1
RUNNUMBER=${2}_${SEQUENCER}
WORKDIR=$3
GROUP=$4
WORKFLOW=${EBROOTNGS_DEMULTIPLEX}/workflow.csv
echo "$WORKDIR AND $RUNNUMBER"
echo "GROUPIE: $GROUP"

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

perl ${EBROOTNGS_DEMULTIPLEX}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DEMULTIPLEX}/parameters_${GROUP}.csv > \
${WORKDIR}/generatedscripts/run_${RUNNUMBER}/parameters_group.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/out.csv \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/parameters_group.csv \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/environment_parameters.csv \
-p ${WORKDIR}/generatedscripts/run_${RUNNUMBER}/run_${RUNNUMBER}.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/runs/run_${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate
