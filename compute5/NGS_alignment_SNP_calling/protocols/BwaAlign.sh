#MOLGENIS walltime=20:00:00 nodes=1 ppn=8 mem=6gb

#Parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string indexFile
#string bwaAlignCores
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string alignedSam
#string lane
#string library
#string externalSampleID

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${seqType}"
echo "bwaVersion: ${bwaVersion}"
echo "indexFile: ${indexFile}"
echo "bwaAlignCores: ${bwaAlignCores}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "alignedSam: ${alignedSam}"
echo "lane: ${lane}"
echo "library: ${library}"
echo "externalSampleID: ${externalSampleID}"


sleep 10

#If paired-end then copy 2 files, else only 1
alloutputsexist \
"${alignedSam}"

getFile ${indexFile}
if [ ${seqType} == "PE" ]
then

	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else

	getFile ${srBarcodeFqGz}

fi

makeTmpDir ${alignedSam} 
tmpAlignedSam=${MC_tmpFile}

#Load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"

#If paired-end use two fq files as input, else only one
if [ ${seqType} == "PE" ]
then
    #Run BWA for paired-end
    bwa mem \
    -M \
    -R $READGROUPLINE \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${peEnd1BarcodeFqGz} \
    ${peEnd2BarcodeFqGz} \
    > ${tmpAlignedSam}

	echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpAlignedSam} ${alignedSam}
	putFile "${alignedSam}"
else
    #Run BWA for single-read
    bwa mem \
    -M \
    -R $READGROUPLINE \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${srBarcodeFqGz} \
    > ${tmpAlignedSam}

	echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpAlignedSam} ${alignedSam}
	putFile "${alignedSam}"
fi

