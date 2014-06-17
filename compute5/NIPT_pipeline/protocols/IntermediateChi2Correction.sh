#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string RVersion
#string RScriptInterChi
#string tempDir
#string intermediateDir
#string controlSetDir
#string binnedSample
#string sampleID
#string strand
#string chiIntermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScriptInterChi}"
echo "tempDir: ${tempdir}"
echo "intermediateDir: ${intermediateDir}"
echo "controlSetDir: ${controlSetDir}"
echo "binnedSample: ${binnedSample}"
echo "sampleID: ${sampleID}"
echo "strand: ${strand}"  
echo "chiIntermediateDir: ${chiIntermediateDir}"



sleep 10



#Load R
${stage} R/${RVersion}
${checkStage}

mkdir -p ${chiIntermediateDir}

Rscript ${RScriptInterChi} \
${controlSetDir} \
${binnedSample} \
${chiIntermediateDir} \
${sampleID} \
${strand}


#Get return code from last program call
returnCode=$?

	
echo -e "\nreturnCode CreateBins: $returnCode\n\n"


