#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6

#Parameter mapping
#string stage
#string checkStage
#string indexFile
#string peEnd2BarcodeFqGz
#string tmpIntermediateDir
#string intermediateDir
#string bwaVersion
#string bwaAlignCores
#string tmpRightBwaOut
#string rightBwaOut
#string seqType



#echo parameter values
if [ ${seqType} == "PE" ]
then
	echo "stage: ${stage}"
	echo "checkStage: ${checkStage}"
	echo "indexFile: ${indexFile}" 
	echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}" 
	echo "tmpIntermediateDir: ${tmpIntermediateDir}"
	echo "intermediateDir: ${intermediateDir}"
	echo "bwaVersion: ${bwaVersion}" 
	echo "bwaAlignCores: ${bwaAlignCores}"
	echo "tmpRightBwaOut: ${tmpRightBwaOut}" 
	echo "rightBwaOut: ${rightBwaOut}" 
	echo "seqType: ${seqType}"

	sleep 10

	alloutputsexist \
	"${rightBwaOut}"

	#get reference file
	getFile ${indexFile} 

	#get left reads
	getFile ${peEnd2BarcodeFqGz}

	#load module BWA
	${stage} bwa/${bwaVersion}
	${checkStage}

	#create tmp dir
	mkdir -p "${tmpIntermediateDir}"

	#run BWA
	bwa aln \
	-t ${bwaAlignCores} \
	${indexFile} \
	${peEnd2BarcodeFqGz} \
	> ${tmpRightBwaOut}

	#get return code from last program call
	returnCode=$?

	echo -e "\nreturnCode BWA: $returnCode\n\n"

	if [ $returnCode -eq 0 ]
    then
        echo -e "\nBWA align right finished succesfull. Moving temp files to final.\n\n"
        mv ${tmpRightBwaOut} ${rightBwaOut}
        putFile "${rightBwaOut}"
    else
        echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
        exit -1
	fi
else

echo "Single end reads. Skipping BwaAlignRight."

fi
