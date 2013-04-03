#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk,sampleChunk

getFile ${convert_from_minimac_prob_to_plink}
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob
getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info
getFile ${studyInputDir}/chr${chr}.ped
getFile ${studyInputDir}/chr${chr}.map

alloutputsexist \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map \
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.concordance

#Convert prob and info files to plink
python ${convert_from_minimac_prob_to_plink} \
	${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.prob \
	${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.info \
	${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped \
	${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map 

returnCode=$?

if [ $returnCode -eq 0 ]
then
	echo 'Convert prob and info files to plink, finished with no apparent problem'
else
       echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
       #Return non zero return code
       exit 1
fi

#Measure concordance with plink
${plink} \
	--file ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed \
	--merge ${studyInputDir}/chr${chr}.ped ${studyInputDir}/chr${chr}.map \
	--merge-mode 6 \
	--noweb \
	--out ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.concordance

returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map
	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.concordance ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.concordance

	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.ped
	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.imputed.map
	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${sampleChunk}.concordance
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
