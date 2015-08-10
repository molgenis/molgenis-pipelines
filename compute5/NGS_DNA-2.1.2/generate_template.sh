#!/bin/bash
module load NGS_DNA/2.1.2
module list

PROJECT=projectXX
TMPDIR=tmp01
RUNID=runXX
## For small batchsize (50) leave BATCH empty, else choose _WGS (500 batches) or _exome (200 batches)
BATCH=""

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f /gcc/groups/gaf/tmp01/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv
fi

sh $MC_HOME/convert.sh $NGS_DNA_HOME/parameters.csv \
/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv

sh $MC_HOME/molgenis_compute.sh \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv \
-p $NGS_DNA_HOME/batchIDList${BATCH}.csv \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $NGS_DNA_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$NGS_DNA_HOME/workflow.csv;\
outputdir=scripts/jobs;mainParameters=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
batchIDList=$NGS_DNA_HOME/batchIDList${BATCH}.csv;\
worksheet=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
