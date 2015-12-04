#!/bin/bash

module load NIPT
module list

### Change at least for every different run the $project and $runid ####
project="<ProjectNameVar>"
runid=run01
cluster="<GccClusterVar>"
ENVIRONMENT_PARAMETERS=parameters_$(cluster).csv
TMPDIR=$(ls -1 /groups/umcg-gd/ |grep tmp)
WORKDIR="/groups/umcg-gd/${TMPDIR}"
WORKFLOW=${EBROOTNIPT}/workflow.csv


if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ ! -f ${WORKDIR}/generatedscripts/${project} ] 
then
	mkdir -p ${WORKDIR}/generatedscripts/${project}/
fi

if [ -f ${WORKDIR}/generatedscripts/${project}/out.csv  ];
then
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
-rundir ${WORKDIR}/projects/${project}/${runid}/jobs \
-b slurm \
-runid ${runid} \
-weave \
--generate

cd $(WORKDIR)/projects/$(project)/$(runid)/jobs/

sh submit.sh
