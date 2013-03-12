#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk

#Construct getFile script
ls -1 ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk*.imputed.prob.transposed | python -c 'import sys; print str.join(" ", ["getFile " + x for x in sorted(sys.stdin.readlines(), key=lambda y:int(y[y.find("sampleChunk") + 11:y.find(".imputed.prob")]))])' > ${imputationResultDir}/~fetch_trasposed_chunk${chrChunk}-chr${chr}.sh

#Execute script and fetch transposed files
sh ${imputationResultDir}/~fetch_trasposed_chunk${chrChunk}-chr${chr}.sh

#Construct script to compute quality metrics
ls -1 ${imputationResultDir}/~chunk${chrChunk}-chr${chr}_sampleChunk*.imputed.prob.transposed | python -c  'import sys; print "${python_exec} ${imputation_quality_metrics_script} -outputs ${imputationResultDir}/~chunk${chrChunk}-chr${chr}.quality -inputs " + str.join(",", [x.replace("\n", "") for x in sorted(sys.stdin.readlines(), key=lambda y:int(y[y.find("sampleChunk") + 11:y.find(".imputed.prob")]))])' > ${imputationResultDir}/~compute_imputation_quality_chunk${chrChunk}-chr${chr}.sh

#Execute the script that computes imputation quality for that chromosome chunk
sh ${imputationResultDir}/~compute_imputation_quality_chunk${chrChunk}-chr${chr}.sh

returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${imputationResultDir}/~fetch_trasposed_chunk${chrChunk}-chr${chr}.sh ${imputationResultDir}/fetch_trasposed_chunk${chrChunk}-chr${chr}.sh
    mv ${imputationResultDir}/compute_imputation_quality_chunk${chrChunk}-chr${chr}.sh ${imputationResultDir}/compute_imputation_quality_chunk${chrChunk}-chr${chr}.sh
    mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}.quality ${imputationResultDir}/chunk${chrChunk}-chr${chr}.quality

    putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}.quality
else

  echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
  #Return non zero return code
	exit 1

fi
