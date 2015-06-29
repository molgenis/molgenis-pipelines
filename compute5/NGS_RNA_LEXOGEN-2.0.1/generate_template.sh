#!/bin/bash
module load NGS_RNA_LEXOGEN/2.0.1
module list

TMPFOLDER="tmp01"
PROJECT="<PROJECTNAME>"
RUNID="run01"

SCRIPTFOLDER="/gcc/groups/gaf/${TMPFOLDER}/generatedscripts/${PROJECT}"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${SCRIPTFOLDER}/parameters.converted.csv  ];
then
        rm -rf ${SCRIPTFOLDER}/parameters.converted.csv
fi

sh ${MC_HOME}/convert.sh ${NGS_RNA_LEXOGEN_HOME}/parameters_${TMPFOLDER}.csv ${SCRIPTFOLDER}/parameters.converted.csv


sh $MC_HOME/molgenis_compute.sh \
-p ${SCRIPTFOLDER}/parameters.converted.csv \
-p ${SCRIPTFOLDER}/${PROJECT}.csv \
-w ${NGS_RNA_LEXOGEN_HOME}/create_in-house_ngs_projects_workflow.csv \
-rundir ${SCRIPTFOLDER}/scripts \
--runid ${RUNID} \
-o "workflowpath=${NGS_RNA_LEXOGEN_HOME}/workflow.csv;\
outputdir=scripts/jobs;mainParameters=$SCRIPTFOLDER/parameters.converted.csv;\
worksheet=$SCRIPTFOLDER/${PROJECT}.csv" \
-weave \
--generate
