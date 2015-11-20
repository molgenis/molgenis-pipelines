#!/bin/bash

module load NGS_RNA 
module list

PROJECT=projectxx
RUNID=runxx
TMPDIR=tmp04
GAF="/groups/umcg-gaf/${TMPDIR}"
BUILD="b38"

SAMPLESIZE=$(cat ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv | wc -l)
if [ $SAMPLESIZE -gt 200 ]
then
        WORKFLOW=${EBROOTNGS_RNA}/workflow_hisat_samplesize_bigger_than_200.csv
else
        WORKFLOW=${EBROOTNGS_RNA}/workflow_hisat.csv
fi

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf ${GAF}/generatedscripts/${PROJECT}/out.csv
fi


perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters.csv > \
${GAF}/generatedscripts/${PROJECT}/out.csv

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters_calculon.${BUILD}.csv > \
${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/out.csv \
-p ${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${WORKFLOW};\
outputdir=scripts/jobs;\
mainParameters=${GAF}/generatedscripts/${PROJECT}/out.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
environment_parameters=${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv;" \
-weave \
--generate
