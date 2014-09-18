#MOLGENIS walltime=23:59:00 ppn=1

#Parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string indexFile
#string intermediateDir
#string peEnd1BarcodeAligned
#string peEnd2BarcodeAligned
#string srBarcodeAligned
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string lane
#string library
#string externalSampleID
#string alignedSam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${stage}"
echo "bwaVersion: ${bwaVersion}"
echo "indexFile: ${indexFile}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeAligned: ${peEnd1BarcodeAligned}"
echo "peEnd2BarcodeAligned: ${peEnd2BarcodeAligned}"
echo "srBarcodeAligned: ${srBarcodeAligned}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "lane: ${lane}"
echo "library: ${library}"
echo "externalSampleID: ${externalSampleID}"
echo "alignedSam: ${alignedSam}"

sleep 10

alloutputsexist \
"${alignedSam}"

#If paired-end then copy 2 files, else only 1
getFile ${indexFile}
if [ ${seqType} == "PE" ]
then
	getFile ${peEnd1BarcodeAligned}
	getFile ${peEnd2BarcodeAligned}
    getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else
	getFile ${srBarcodeAligned}
    getFile ${srBarcodeFqGz}
fi

#Load BWA
${stage} bwa/${bwaVersion}
${checkStage}

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"

makeTmpDir ${alignedSam}
tmpAlignedSam=${MC_tmpFile}


#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
    #Run BWA sampe
    bwa sampe \
    -r $READGROUPLINE \
    ${indexFile} \
    ${peEnd1BarcodeAligned} \
    ${peEnd2BarcodeAligned} \
    ${peEnd1BarcodeFqGz} \
    ${peEnd2BarcodeFqGz} \
    > ${tmpAlignedSam}

		echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpAlignedSam} ${alignedSam}
		putFile "${alignedSam}"

else
    #Run BWA samse
    bwa samse \
    -r $READGROUPLINE \
    ${indexFile} \
    ${srBarcodeAligned} \
    ${srBarcodeFqGz} \
    > ${tmpAlignedSam}

	echo -e "\nBWA samse finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpAlignedSam} ${alignedSam}
	putFile "${alignedSam}"

fi
