#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string RVersion
#string RScriptNCV
#string tempDir
#string intermediateDir
#string controlSetDir
#string chiIntermediateDir
#string PredictOut4Preds
#string fractionTable
#string sampleID
#string ncvOutStats4Preds
#string chromoFocus



#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScriptNCV}"
echo "tempDir: ${tempdir}"
echo "intermediateDir: ${intermediateDir}"
echo "controlSetDir: ${controlSetDir}"
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "PredictOut4Preds: ${PredictOut4Preds}"
echo "fractionTable: ${fractionTable}" 
echo "ncvOutStats: ${ncvOutStats4Preds}"
echo "sampleID: ${sampleID}" 
echo "chromoFocus: ${chromoFocus}"

sleep 10

#Load R
${stage} R/${RVersion}
${checkStage}



Rscript ${RScriptNCV} \
${fractionTable} \
${PredictOut4Preds} \
${sampleID} \
${ncvOutStats4Preds} \
${chiIntermediateDir} \
${chromoFocus}


#Get return code from last program call
returnCode=$?

	
echo -e "\nreturnCode DetermineNCV: $returnCode\n\n"


