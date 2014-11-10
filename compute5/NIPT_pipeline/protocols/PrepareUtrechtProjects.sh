#!/bin/bash =====================================================

#string tempDir
#string project
#string scriptDir
#string gccGuestAccount
#string gccGuestAccountFolder
#string sambamba
#string ProjectUtrecht
#string workflowpath
#string outputdir
#string mainParameters
#string worksheet
#string keyName
#list DNA_nr
#list externalSampleID

#
# Change permissions.
#
umask 0007

set -e
set -u

#
# load Modules
#

module load jdk
module load molgenis-compute/v5_20140801
module list

#
# Create project dirs.
#
mkdir -p ${tempDir}/${project}/${runid}

#
# put BamFileNames in INPUTSBAMS 
#

for externalID in "${externalSampleID[@]}"
do
	INPUTS+=("/${ProjectUtrecht}/${externalID}/${externalID}.bam,")
	INPUTS+=("/${ProjectUtrecht}/${externalID}/${externalID}.bam.bai,")
done

INPUTSBAMS=$( printf "%s" "${INPUTS[@]}" )

#
# Rsync data to runfolder
#
echo "Start rsync BAMfile from GCC cluster to ${tempDir}/${project}/${runid}"

rsync -e "ssh -i ${HOME}/.ssh/${keyName} \
-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" -v \
${gccGuestAccount}:${gccGuestAccountFolder}/{${INPUTSBAMS[@]}} ${tempDir}/${project}/${runid}


echo "rsync done"

#
# filter bams using Sambamba 
#
echo "filter bams using Sambamba"

python ${scriptDir}/NIPT/Filter_BAMs_NIPT.py -x ${tempDir}/${project}/${runid} -s ${sambamba} 

#
# Clear up after Filter_BAMs_NIPT.py
#
COUNTER=0
for externalID in "${externalSampleID[@]}"
do

	mv ${tempDir}/${project}/${runid}/${externalID}_u0mm_subopt.bam ${tempDir}/${project}/${runid}/${DNA_nr[$COUNTER]}_${externalSampleID[$COUNTER]}.merged.bam
	mv ${tempDir}/${project}/${runid}/${externalID}_u0mm_subopt.bam.bai ${tempDir}/${project}/${runid}/${DNA_nr[$COUNTER]}_${externalSampleID[$COUNTER]}.merged.bai
	
	rm ${tempDir}/${project}/${runid}/${externalID}.bam
	rm ${tempDir}/${project}/${runid}/${externalID}.bam.bai
	
	COUNTER=$(($COUNTER+1))
done

echo "Sambamba done"

#
# Execute MOLGENIS/compute to create NIPT job scripts to analyse this project.
#

if [ -f .compute.properties ];
then
        rm .compute.properties
fi

$MC_HOME/molgenis_compute.sh \
--generate \
-b pbs \
--parameters ${mainParameters} \
--parameters ${worksheet} \
--workflow ${workflowpath} \
-rundir ${outputdir} \
-header ${MC_HOME}/templates/pbs/header.ftl \
--runid ${runid}


#
# Fix write permissions for group for tmp and scripts folder.
#
chmod -R g+rw ${tempDir}/${project}/
chmod -R g+rw ${outputdir}

sh ${outputdir}/submit.sh
