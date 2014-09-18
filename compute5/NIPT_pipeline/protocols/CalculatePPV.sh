#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string chiIntermediateDir
#string apriori13
#string apriori18
#string apriori21
#string sampleID
#string RVersion
#string RscriptPPV

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "chiIntermediateDir: ${chiIntermediateDir}"
echo "apriori13: ${apriori13}"
echo "apriori18: ${apriori18}"
echo "apriori21: ${apriori21}"
echo "sampleID: ${sampleID}"
echo "RVersion: ${RVersion}"
echo "Rscript: ${RscriptPPV}"


#Load R
${stage} R/${RVersion}
${checkStage}


Rscript ${RscriptPPV} \
${chiIntermediateDir} \
${apriori13} \
${apriori18} \
${apriori21} \
${sampleID}
	