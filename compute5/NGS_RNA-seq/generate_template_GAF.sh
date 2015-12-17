#!/bin/bash

#module load NGS_RNA-seq
module load Molgenis-Compute/v15.04.1-Java-1.7.0_80
module list

PROJECT=projectxx
RUNID=runxx
TMPDIR=tmp04
GAF="/groups/umcg-gaf/${TMPDIR}"

EBROOTNGS_RNAMINSEQ="/groups/umcg-gaf/tmp04/umcg-gvdvries/software/pipelines/molgenis-pipelines/compute5/NGS_RNA-seq/"



SAMPLESIZE=$(cat ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv | wc -l)
if [ $SAMPLESIZE -gt 200 ]
then
        WORKFLOW=${EBROOTNGS_RNAMINSEQ}/workflow_GAF_samplesize_bigger_than_200.csv
else
        WORKFLOW=${EBROOTNGS_RNAMINSEQ}/workflow_GAF.csv
fi

if [ -f .compute.properties ];
then
     rm .compute.properties
fi


perl ${EBROOTNGS_RNAMINSEQ}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNAMINSEQ}/parameters_GAF.csv > \
${GAF}/generatedscripts/${PROJECT}/parameters.converted.csv

perl ${EBROOTNGS_RNAMINSEQ}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNAMINSEQ}/environment_parameters.csv > \
${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.converted.csv \
-p ${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_RNAMINSEQ}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${WORKFLOW};\
outputdir=scripts/jobs;\
mainParameters=${GAF}/generatedscripts/${PROJECT}/parameters.converted.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
environment_parameters=${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv;" \
-weave \
--generate
