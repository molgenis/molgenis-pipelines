#!/bin/bash

module load NGS_RNA/3.1.3-Molgenis-Compute-v15.04.1-Java-1.7.0_80 
module list

PROJECT=projectxx
RUNID=runxx
TMPDIR=tmp04
GAF="/groups/umcg-gaf/${TMPDIR}"

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

perl ${EBROOTNGS_RNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNA}/parameters_calculon.csv > \
${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/out.csv \
-p ${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_RNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$EBROOTNGS_RNA/workflow_hisat.csv;\
outputdir=scripts/jobs;mainParameters=${GAF}/generatedscripts/${PROJECT}/out.csv;\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv;environment_parameters=${GAF}/generatedscripts/${PROJECT}/environment_parameters.csv;"\
-weave \
--generate
