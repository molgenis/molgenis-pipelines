#!/bin/bash

set -e 
set -u

### NEEDS 2 arguments! PROJECT AND BATCH

module load NGS_DNA/3.2.5
module list 
HOST=$(hostname)
THISDIR=$(pwd)

ENVIRONMENT_PARAMETERS="parameters_${HOST%%.*}.csv"
TMPDIRECTORY=$(basename $(cd ../../ && pwd ))
GROUP=$(basename $(cd ../../../ && pwd ))

PROJECT=$1
WORKDIR="/groups/${GROUP}/${TMPDIRECTORY}"
RUNID=run01

## Normal user, please leave BATCH at _chr
## Expert modus: small batchsize (6) fill in '_small', per chromsome '_chr'
BATCH=$2

##Some error handling
function errorExitandCleanUp()
{
        echo "TRAPPED"
	if [ ! -f /groups/${GROUP}/${TMPDIRECTORY}/logs/${PROJECT}.generating.failed.mailed ]
        then
              	mailTo="helpdesk.gcc.groningen@gmail.com"
                tail -50 ${WORKDIR}/generatedscripts/${PROJECT}/generate.logger	| mail -s "The generate script has crashed for run/project ${PROJECT}" ${mailTo}
                touch /groups/${GROUP}/${TMPDIRECTORY}/logs/${PROJECT}.generating.failed.mailed 
        fi
}
trap "errorExitandCleanUp" HUP INT QUIT TERM EXIT ERR

SAMPLESIZE=$(( $(sh ${EBROOTNGS_DNA}/samplesize.sh ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv $THISDIR) -1 ))
echo "Samplesize is $SAMPLESIZE"
if [ $SAMPLESIZE -gt 199 ]
then
    	WORKFLOW=${EBROOTNGS_DNA}/workflow_samplesize_bigger_than_200.csv
else
    	WORKFLOW=${EBROOTNGS_DNA}/workflow.csv
fi

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${WORKDIR}/generatedscripts/${PROJECT}/out.csv  ];
then
    	rm -rf ${WORKDIR}/generatedscripts/${PROJECT}/out.csv
fi

echo "tmpName,${TMPDIRECTORY}" > ${WORKDIR}/generatedscripts/${PROJECT}/tmpdir_parameters.csv

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${WORKDIR}/generatedscripts/${PROJECT}/tmpdir_parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/tmpdir_parameters_converted.csv

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/out.csv

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/parameters_${GROUP}.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/group_parameters.csv

perl ${EBROOTNGS_DNA}/convertParametersGitToMolgenis.pl ${EBROOTNGS_DNA}/${ENVIRONMENT_PARAMETERS} > \
${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/out.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/group_parameters.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv \
-p ${EBROOTNGS_DNA}/batchIDList${BATCH}.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/tmpdir_parameters_converted.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv \
-w ${EBROOTNGS_DNA}/create_in-house_ngs_projects_workflow.csv \
-rundir ${WORKDIR}/generatedscripts/${PROJECT}/scripts \
--runid ${RUNID} \
-o "workflowpath=${WORKFLOW};\
outputdir=scripts/jobs;mainParameters=${WORKDIR}/generatedscripts/${PROJECT}/out.csv;\
group_parameters=${WORKDIR}/generatedscripts/${PROJECT}/group_parameters.csv;\
groupname=${GROUP};\
ngsversion=$(module list | grep -o -P 'NGS_DNA(.+)');\
environment_parameters=${WORKDIR}/generatedscripts/${PROJECT}/environment_parameters.csv;\
tmpdir_parameters=${WORKDIR}/generatedscripts/${PROJECT}/tmpdir_parameters_converted.csv;\
batchIDList=${EBROOTNGS_DNA}/batchIDList${BATCH}.csv;\
worksheet=${WORKDIR}/generatedscripts/${PROJECT}/${PROJECT}.csv" \
-weave \
--generate

trap - EXIT
exit 0
