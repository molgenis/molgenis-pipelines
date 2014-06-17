#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string RVersion
#string RScriptDetermineControl
#string tempDir
#string intermediateDir
#string sampleID
#string chiIntermediateDir
#string controlSetCharacteristics
#string bestControlSet



#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScriptDetermineControl}"
echo "tempDir: ${tempdir}"
echo "intermediateDir: ${intermediateDir}"
echo "sampleID: ${sampleID}"
echo "sampleDir: ${sampleDir}"
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "controlsetCharacteristics: ${controlSetCharacteristics}"
echo "bestControlSet: ${bestControlSet}"


sleep 10



#Load R
${stage} R/${RVersion}
${checkStage}

Rscript \
${RScriptDetermineControl} \
${chiIntermediateDir} \
${sampleID} \
${controlSetCharacteristics} \
${bestControlSet} 



#Get return code from last program call
returnCode=$?

	
echo -e "\nreturnCode CreateBins: $returnCode\n\n"
