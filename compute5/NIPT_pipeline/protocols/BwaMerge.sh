#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6

#parameter mapping
#string stage
#string checkStage
#string seqType
#string bwaVersion
#string bwaAlignCores
#string intermediateDir
#string tmpIntermediateDir
#string indexFile
#string leftBwaOut
#string rightBwaOut
#string tmpAlignedSam
#string alignedSam
#string lane
#string library
#string externalSampleID
#string bwaInput


#echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "seqType: ${seqType}"
echo "bwaVersion: ${bwaVersion}" 
echo "bwaAlignCores: ${bwaAlignCores}"
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "leftBwaOut: ${leftBwaOut}"
echo "rightBwaOut: ${rightBwaOut}"
echo "tmpAlignedSam: ${tmpAlignedSam}"
echo "alignedSam: ${alignedSam}"
echo "lane: ${lane}"
echo "library: ${library}"
echo "externalSampleID: ${externalSampleID}"
echo "bwaInput: ${bwaInput}"

sleep 10


#get files
getFile ${indexFile}

getFile ${leftBwaOut}
getFile ${bwaInput}



alloutputsexist \
"${alignedSam}" 


#Load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

#Create tmp dir
mkdir -p "${tmpIntermediateDir}"

READGROUPLINE="@RG\tID:${lane}\tPL:illumina\tLB:${library}\tSM:${externalSampleID}"


#run bwa in samse mode	
echo "Running bwa" 
	bwa samse \
	-r ${READGROUPLINE} \
	${indexFile} \
	${leftBwaOut} \
	${bwaInput} \
	> ${tmpAlignedSam}
	
#get return code from last program call
returnCode=$?

echo -e "\nreturnCode BWA: $returnCode\n\n"
	
	 if [ $returnCode -eq 0 ]
    then
    		echo -e "\nBWA sampe finished succesfull. Moving temp files to final.\n\n"
    		mv ${tmpAlignedSam} ${alignedSam}
    		putFile "${alignedSam}"
    else
    		echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
            exit -1
    fi
 
	
	
	
	
	
	
	
	

