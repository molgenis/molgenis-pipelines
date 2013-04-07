#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk,sampleChunk

getFile ${convert_from_minimac_prob_to_plink}
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info

alloutputsexist \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map

python ${convert_from_minimac_prob_to_plink} \
	${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob \
	${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info \
	${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped \
	${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map


#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map

	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
