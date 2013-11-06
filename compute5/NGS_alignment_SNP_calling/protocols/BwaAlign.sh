#MOLGENIS walltime=20:00:00 nodes=1 ppn=4 mem=6gb

#Parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string indexFile
#string tmpIntermediateDir
#string bwaAlignCores
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string tmpPeEnd1BarcodeAligned
#string tmpPeEnd2BarcodeAligned
#string intermediateDir
#string tmpIntermediateDir
#string tmpSrBarcodeAligned
#string peEnd1BarcodeAligned
#string peEnd2BarcodeAligned
#string srBarcodeAligned


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${seqType}"
echo "bwaVersion: ${bwaVersion}"
echo "indexFile: ${indexFile}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "bwaAlignCores: ${bwaAlignCores}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "tmpPeEnd1BarcodeAligned: ${tmpPeEnd1BarcodeAligned}"
echo "tmpPeEnd2BarcodeAligned: ${tmpPeEnd2BarcodeAligned}"
echo "peEnd1BarcodeAligned: ${peEnd1BarcodeAligned}"
echo "peEnd2BarcodeAligned: ${peEnd2BarcodeAligned}"
echo "intermediateDir: ${intermediateDir}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "tmpSrBarcodeAligned: ${tmpSrBarcodeAligned}"
echo "srBarcodeAligned: ${srBarcodeAligned}"

sleep 10

#If paired-end then copy 2 files, else only 1
getFile ${indexFile}
if [ ${seqType} == "PE" ]
then
        alloutputsexist \
        "${peEnd1BarcodeAligned}" \
        "${peEnd2BarcodeAligned}"
    
	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else
        alloutputsexist \
        "${srBarcodeAligned}"
        
	getFile ${srBarcodeFqGz}

fi

#Load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

#Create tmp dir
mkdir -p "${tmpIntermediateDir}"

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
    #Run BWA first time
    bwa aln \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${peEnd1BarcodeFqGz} \
    -f ${tmpPeEnd1BarcodeAligned}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: ${returnCode}\n\n"

    if [ $returnCode -eq 0 ]
    then
		echo -e "\nBWA aln finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpPeEnd1BarcodeAligned} ${peEnd1BarcodeAligned}
		putFile "${peEnd1BarcodeAligned}"
    else
		echo -e "\nFailed to move BWA aln results to ${intermediateDir}\n\n"
		exit -1
    fi

    #Run BWA second time
    bwa aln \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${peEnd2BarcodeFqGz} \
    -f ${tmpPeEnd2BarcodeAligned}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: ${returnCode}\n\n"

    if [ $returnCode -eq 0 ]
    then
		echo -e "\nBWA aln finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpPeEnd2BarcodeAligned} ${peEnd2BarcodeAligned}
		putFile "${peEnd2BarcodeAligned}"
    else
		echo -e "\nFailed to move BWA aln results to ${intermediateDir}\n\n"
		exit -1
    fi
    
else
    #Run BWA for single-read
    bwa aln \
    -t ${bwaAlignCores} \
    ${indexFile} \
    ${srBarcodeFqGz} \
    -f ${tmpSrBarcodeAligned}
	
    #Get return code from last program call
    returnCode=$?

    echo -e "\nreturnCode BWA: ${returnCode}\n\n"

    if [ $returnCode -eq 0 ]
    then
		echo -e "\nBWA aln finished succesfull. Moving temp files to final.\n\n"
		mv ${tmpSrBarcodeAligned} ${srBarcodeAligned}
		putFile "${srBarcodeAligned}"
    else
		echo -e "\nFailed to move BWA aln results to ${intermediateDir}\n\n"
		exit -1
    fi
fi

