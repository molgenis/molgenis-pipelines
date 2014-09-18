#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string RVersion
#string RScriptChi
#string tempDir
#string intermediateDir
#string controlSetDir
#string binnedSample
#string bestControlSet
#string strand
#string sampleID
#string chiIntermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "RVersion: ${RVersion}"
echo "RScript: ${RScriptChi}"
echo "tempDir: ${tempdir}"
echo "intermediateDir: ${intermediateDir}"
echo "controlSetDir: ${controlSetDir}"
echo "binnedSample: ${binnedSample}"
echo "bestControlSet: ${bestControlSet}"
echo "strand: ${strand}" 
echo "sampleID: ${sampleID}"
echo "chiIntermediateDir: ${chiIntermediateDir}"



sleep 10



#Load R
${stage} R/${RVersion}
${checkStage}



Rscript ${RScriptChi} \
${controlSetDir} \
${binnedSample} \
${chiIntermediateDir} \
${bestControlSet} \
${strand} \
${sampleID}



#Get return code from last program call
returnCode=$?

	
echo -e "\nreturnCode CreateBins: $returnCode\n\n"


