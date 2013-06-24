#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk,sampleChunk

getFile ${convert_from_minimac_prob_to_plink}
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info

alloutputsexist \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz

${dose_to_plink} \
	-t prob \
	-d ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob \
	-i ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info \
	-o ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz

#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz
	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.plink.dose.gz
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
