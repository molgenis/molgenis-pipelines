#!/bin/bash

module load NGS_RNA/3.2.3-Molgenis-Compute-v16.05.1-Java-1.8.0_45
module list

HOST=$(hostname)
##Running script for checking the environment variables
sh ${EBROOTNGS_RNA}/checkEnvironment.sh ${HOST}

ENVIRONMENT_PARAMETERS=$(awk '{print $1}' ./environment_checks.txt)
TMPDIR=$(awk '{print $2}' ./environment_checks.txt)
GROUP=$(awk '{print $3}' ./environment_checks.txt)

GAF="/groups/${GROUP}/${TMPDIR}"
BUILD="b37" # b37, b38
ENVIRONMENT="calculon" # zinc-finger, calculon

SPECIES="homo_sapiens" # callithrix_jacchus, mus_musculus, homo_sapiens
PIPELINE="hisat" # hisat, lexogen

WORKFLOW=${EBROOTNGS_RNA}/workflow_${PIPELINE}.csv

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf ${GAF}/generatedscripts/${PROJECT}/out.csv
fi

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.csv > \
${GAF}/generatedscripts/${PROJECT}/parameters.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${BUILD}.csv > \
${GAF}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${SPECIES}.csv > \
${GAF}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.${ENVIRONMENT}.csv > \
${GAF}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.csv \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-p ${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv \
-w ${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
--weave \
--generate \
-o "workflowpath=${WORKFLOW};outputdir=scripts/jobs;\
groupname=${GROUP};\
mainParameters=${GAF}/generatedscripts/${PROJECT}/parameters.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
parameters_build=${GAF}/generatedscripts/${PROJECT}/parameters.${BUILD}.csv;\
parameters_species=${GAF}/generatedscripts/${PROJECT}/parameters.${SPECIES}.csv;\
parameters_chromosomes=${EBROOTNGS_RNA}/chromosomes.${SPECIES}.csv;\
parameters_environment=${GAF}/generatedscripts/${PROJECT}/parameters.${ENVIRONMENT}.csv;"
