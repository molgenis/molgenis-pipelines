#!/bin/bash

module load NGS_RNA-seq/3.2.1-Molgenis-Compute-v15.12.4-Java-1.8.0_45
module list

PROJECT=projectName
RUNID=run01
TMPDIR=tmp04
GAF="/groups/umcg-gaf/${TMPDIR}"
SEQTYPE="SR"  # SR or PE




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

perl ${EBROOTNGS_RNAMINSEQ}/convertParametersGitToMolgenis.pl ${EBROOTNGS_RNAMINSEQ}/environment_parameters.${SEQTYPE}.GAF.csv > \
${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv

sh ${EBROOTMOLGENISMINCOMPUTE}/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/parameters.converted.csv \
-p ${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-p ${EBROOTNGS_RNAMINSEQ}/chromosomes.csv \
-w ${EBROOTNGS_RNAMINSEQ}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${WORKFLOW};\
mainParameters=${GAF}/generatedscripts/${PROJECT}/parameters.converted.csv;\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv;\
environment_parameters=${GAF}/generatedscripts/${PROJECT}/environment.parameters.converted.csv;\
ngsversion=$(module list | grep -o -P 'NGS_RNA(.+)');"\
-weave \
--generate
