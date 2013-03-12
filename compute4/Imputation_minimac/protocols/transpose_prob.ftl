#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk,sampleChunk

getFile ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob
getFile ${transpose_script}

#Transpose the probs file
${python_exec} ${transpose_script} ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob.transposed

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob.transposed ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob.transposed

    putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob.transposed
else

  echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
