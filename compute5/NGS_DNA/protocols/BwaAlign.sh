#MOLGENIS walltime=20:00:00 nodes=1 ppn=8 mem=10gb

#Parameter mapping
#string tmpName
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
#string externalSampleID
#string tmpDataDir
#string project
#string logsDir
#string intermediateDir
#string filePrefix

makeTmpDir ${alignedSam} 
tmpAlignedSam=${MC_tmpFile}

#Load module BWA
${stage} ${bwaVersion}
${checkStage}

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${filePrefix}\tSM:${externalSampleID}"

#If paired-end use two fq files as input, else only one
if [ "${seqType}" == "PE" ]
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
fi


