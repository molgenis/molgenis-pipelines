#!/bin/bash
module load jdk/1.7.0_51
NGS_DNA_HOME="/gcc/tools/NGS_DNA-2.1.1/"
module load molgenis-compute/v5_20150211
module list

PROJECT=projectXX
TMPDIR=tmp01
RUNID=runXX

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
-p $NGS_DNA_HOME/batchIDList.csv \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $NGS_DNA_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$NGS_DNA_HOME/workflow.csv;\
outputdir=scripts/jobs;mainParameters=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
batchIDList=$NGS_DNA_HOME/batchIDList.csv;\
worksheet=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
