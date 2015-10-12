#!/bin/bash

module load NGS_Demultiplex
module list

ENVIRONMENT_PARAMETERS=parameters_zinc-finger.csv
TMPDIR=tmp05
WORKDIR="/groups/umcg-gaf/${TMPDIR}"
RUNNUMBER=run0674
WORKFLOW=${EBROOTNGSMINDEMULTIPLEX}/workflow.csv

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/tmp_${RUNNUMBER}/

if [ -f ${WORKDIR}/generatedscripts/tmp_${RUNNUMBER}/out.csv  ];
then
    	rm -rf ${WORKDIR}/generatedscripts/tmp_${RUNNUMBER}/out.csv
fi

perl ${EBROOTNGS_Demultiplex}/convertParametersGitToMolgenis.pl ${EBROOTNGS_Demultiplex}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/environment_parameters.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/tmp_${RUNNUMBER}/out.csv \
-p ${WORKDIR}/generatedscripts/tmp_${RUNNUMBER}/environment_parameters.csv \
-p ${WORKDIR}/generatedscripts/${RUNNUMBER}.csv \
-w ${EBROOTNGSMINDEMULTIPLEX}/${WORKFLOW} \
-rundir ${WORKDIR}/runs/${RUNNUMBER}/ \
-weave \
--generate

chmod 770 .compute.properties
