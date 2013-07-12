#MOLGENIS walltime=23:59:00 ppn=1

#Parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string indexFile
#string tmpIntermediateDir
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
#string tmpAlignedSam
#string alignedSam
#output OUTalignedSam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${stage}"
echo "bwaVersion: ${bwaVersion}"
echo "indexFile: ${indexFile}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
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
echo "tmpAlignedSam: ${tmpAlignedSam}"
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

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
    #Run BWA sampe
    bwa sampe \
    -r "\'@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}\'"
    ${indexFile} \
    ${peEnd1BarcodeAligned} \
    ${peEnd2BarcodeAligned} \
    ${peEnd1BarcodeFqGz} \
    ${peEnd2BarcodeFqGz} \
    > ${tmpAlignedSam}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: ${returnCode}\n\n"

    if [ $returnCode -eq 0 ]
    then
	echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpAlignedSam} ${alignedSam}
	putFile "${alignedSam}"
    else
	echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
	exit -1
    fi
else
    #Run BWA samse
    bwa sampe \
    -r "\'@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}\'"
    ${indexFile} \
    ${srBarcodeAligned} \
    ${srBarcodeFqGz} \
    > ${tmpAlignedSam}
    
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: ${returnCode}\n\n"

    if [ $returnCode -eq 0 ]
    then
	echo -e "\nBWA samse finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpAlignedSam} ${alignedSam}
	putFile "${alignedSam}"
    else
	echo -e "\nFailed to move BWA samse results to ${intermediateDir}\n\n"
	exit -1
    fi
fi

#Map output vars
OUTalignedSam=${alignedSam}