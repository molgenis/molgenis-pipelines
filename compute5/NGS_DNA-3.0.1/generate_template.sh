#!/bin/bash

module load NGS_DNA-3.0.1-Molgenis-Compute-v15.04.1-Java-1.7.0_80
module list

PROJECT=projectXX
TMPDIR=tmp04
RUNID=runXX
## For small batchsize (50) leave BATCH empty, else choose _wgs or _exome (100 batches) 
BATCH=""

GAF="/groups/umcg-gaf/"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv  ];
then
    	rm -rf ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv
fi

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${NGS_DNA_HOME}/parameters.csv > \
${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv \
-p $NGS_DNA_HOME/batchIDList${BATCH}.csv \
-p ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $NGS_DNA_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${EBROOTNGS_DNA}/workflow.csv;\
outputdir=scripts/jobs;mainParameters=${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
batchIDList=${EBROOTNGS_DNA}/batchIDList${BATCH}.csv;\
worksheet=${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
