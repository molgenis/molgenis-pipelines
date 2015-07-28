#!/bin/bash
NGS_DNA_HOME="/groups/umcg-gaf/tmp04/software/NGS_DNA-3.0.1/"
EBROOTMOLGENISMINCOMPUTE=/apps/software/Molgenis-Compute/v15.04.1-Java-1.7.0_80

#NGS_DNA_HOME="/gcc/tools/NGS_DNA-2.1.1/"
#module load molgenis-compute/v5_20150211
#module list

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

perl ${NGS_DNA_HOME}/convertParametersGitToMolgenis.pl ${NGS_DNA_HOME}/parameters.csv > \
${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv \
-p $NGS_DNA_HOME/batchIDList${BATCH}.csv \
-p ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w $NGS_DNA_HOME/create_in-house_ngs_projects_workflow.csv \
-rundir ${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=$NGS_DNA_HOME/workflow.csv;\
outputdir=scripts/jobs;mainParameters=${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/out.csv;\
batchIDList=$NGS_DNA_HOME/batchIDList${BATCH}.csv;\
worksheet=${GAF}/${TMPDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate
