#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6

#Parameter mapping
#string stage
#string checkStage
#string indexFile
#string peEnd1BarcodeFqGz
#string tmpIntermediateDir
#string intermediateDir
#string bwaVersion
#string bwaAlignCores
#string tmpLeftBwaOut
#string leftBwaOut



#echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "indexFile: ${indexFile}" 
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}" 
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "intermediateDir: ${intermediateDir}"
echo "bwaVersion: ${bwaVersion}" 
echo "bwaAlignCores: ${bwaAlignCores}"
echo "leftBwaOut: ${leftBwaOut}" 
echo "tmpLeftBwaOut: ${tmpLeftBwaOut}" 

sleep 10

alloutputsexist \
"${leftBwaOut}"

#get reference file
getFile ${indexFile} 

#get left reads
getFile ${peEnd1BarcodeFqGz}

#load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

#create tmp dir
mkdir -p "${tmpIntermediateDir}"

#run BWA
bwa aln \
-t ${bwaAlignCores} \
${indexFile} \
${peEnd1BarcodeFqGz} \
> ${tmpLeftBwaOut}

#get return code from last program call
returnCode=$?

echo -e "\nreturnCode BWA: $returnCode\n\n"

if [ $returnCode -eq 0 ]
    then
        echo -e "\nBWA align left finished succesfull. Moving temp files to final.\n\n"
        mv ${tmpLeftBwaOut} ${leftBwaOut}
        putFile "${leftBwaOut}"
    else
        echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
        exit -1
fi


