#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string RVersion
#string RScriptPred
#string tempDir
#string intermediateDir
#string controlSetDir
#string chiIntermediateDir
#string PredictOut4Preds
#string PredictOut5Preds
#string fractionTable
#string sampleID
#string chromoFocus


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScriptPred}"
echo "tempDir: ${tempdir}"
echo "intermediateDir: ${intermediateDir}"
echo "controlSetDir: ${controlSetDir}"
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "PredictOut: ${PredictOut4Preds}"
echo "PredictOut: ${PredictOut5Preds}" 
echo "fractionTable: ${fractionTable}" 
echo "sampleID: ${sampleID}"
echo "chromoFocus: ${chromoFocus}"

sleep 10

#Load R
${stage} R/${RVersion}
${checkStage}



Rscript ${RScriptPred} \
${chiIntermediateDir} \
${PredictOut4Preds} \
${PredictOut5Preds} \
${fractionTable} \
${sampleID} \
${chromoFocus}


#Get return code from last program call
returnCode=$?

	
echo -e "\nreturnCode DetermineBestPredictors: $returnCode\n\n"


