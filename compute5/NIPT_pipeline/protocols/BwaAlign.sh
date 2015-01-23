#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6
#DOC Align reads with BWA

#Parameter mapping
#string stage
#string checkStage
#string indexFile
#string bwaInput
#string tmpIntermediateDir
#string intermediateDir
#string bwaVersion
#string bwaAlignCores
#string tmpBwaOutput
#string bwaOutput



#echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "indexFile: ${indexFile}" 
echo "bwaInput: ${bwaInput}" 
echo "tmpIntermediateDir: ${tmpIntermediateDir}"
echo "intermediateDir: ${intermediateDir}"
echo "bwaVersion: ${bwaVersion}" 
echo "bwaAlignCores: ${bwaAlignCores}"
echo "bwaOutput: ${bwaOutput}" 
echo "tmpBwaOutput: ${tmpBwaOutput}" 

sleep 10

alloutputsexist \
"${bwaOutput}"

#get reference file
getFile ${indexFile} 

#get left reads
getFile ${bwaInput}

#load module BWA
${stage} bwa/${bwaVersion}
${checkStage}

#create tmp dir
mkdir -p "${tmpIntermediateDir}"

#run BWA
bwa aln \
-t ${bwaAlignCores} \
${indexFile} \
${bwaInput} \
> ${tmpBwaOutput}

#get return code from last program call
returnCode=$?

echo -e "\nreturnCode BWA: $returnCode\n\n"

if [ $returnCode -eq 0 ]
    then
        echo -e "\nBWA align left finished succesfull. Moving temp files to final.\n\n"
        mv ${tmpBwaOutput} ${bwaOutput}
        putFile "${bwaOutput}"
    else
        echo -e "\nFailed to move BWA sampe results to ${intermediateDir}\n\n"
        exit -1
fi