#!/bin/bash
module load NGS_DNA/v2.0 
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
-p $NGS_DNA_HOME/chrParameters.csv \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $NGS_DNA_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$NGS_DNA_HOME/workflow.csv;\
outputdir=scripts/jobs;mainParameters=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
chrParameters=$NGS_DNA_HOME/chrParameters.csv;\
worksheet=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
