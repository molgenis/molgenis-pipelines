#!/bin/bash

module load NGS_DNA/3.0.1-Molgenis-Compute-v15.04.1-Java-1.7.0_80
module list

PROJECT=projectXX
TMPDIR=tmp04
GAF="/groups/umcg-gaf/${TMPDIR}"
RUNID=runXX
## For small batchsize (25) leave BATCH empty, else choose _wgs or _exome (100 batches) 
BATCH=""


if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/generatedscripts/${PROJECT}/out.csv  ];
then
    	rm -rf ${GAF}/generatedscripts/${PROJECT}/out.csv
fi

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/parameters.csv > \
${GAF}/generatedscripts/${PROJECT}/out.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${GAF}/generatedscripts/${PROJECT}/out.csv \
-p ${EBROOTNGS_DNA}/batchIDList${BATCH}.csv \
-p ${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_DNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${EBROOTNGS_DNA}/workflow.csv;\
outputdir=scripts/jobs;mainParameters=${GAF}/generatedscripts/${PROJECT}/out.csv;\
batchIDList=${EBROOTNGS_DNA}/batchIDList${BATCH}.csv;\
worksheet=${GAF}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
