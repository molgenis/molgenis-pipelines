#!/bin/bash
module load jdk/1.7.0_51
module load molgenis_compute/v5_20140522
module load NGS_alignment_SNP_calling/v2.0 
module list

PROJECT=projectname
TMPDIR=tmp01
RUNID=run

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f /gcc/groups/gaf/tmp01/generatedscripts/${PROJECT}/out.csv  ];
then
	rm -rf /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv
fi

sh $MC_HOME/convert.sh $MP_HOME/parameters.csv \
/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv

sh $MC_HOME/molgenis_compute.sh \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv \
-p $MP_HOME/chrParameters.csv \
-p /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $MP_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir /gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$MP_HOME/workflow.csv;\
outputdir=scripts/jobs;mainParameters=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
chrParameters=$MP_HOME/chrParameters.csv;\
worksheet=/gcc/groups/gaf/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
