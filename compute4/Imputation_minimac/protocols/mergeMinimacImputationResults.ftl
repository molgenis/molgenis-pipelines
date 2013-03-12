#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project,chr,chrChunk

<#list sampleChunk as chnk>

getFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${chnk}.imputed.dose
inputs "${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${chnk}.imputed.dose"
getFile ${studyPedMapChrDir}/chr${chr}_sampleChunk${chnk}.ped
inputs "${studyPedMapChrDir}/chr${chr}_sampleChunk${chnk}.ped"

</#list>


#Cat sampleChunks together
cat \
<#list sampleChunk as chnk>
${imputationResultDir}/chunk${chrChunk}-chr${chr}_sampleChunk${chnk}.imputed.dose \
</#list>
> ${imputationResultDir}/~chunk${chrChunk}-chr${chr}.imputed.dose

#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chunk${chrChunk}-chr${chr}.imputed.dose ${imputationResultDir}/chunk${chrChunk}-chr${chr}.imputed.dose

	putFile ${imputationResultDir}/chunk${chrChunk}-chr${chr}.imputed.dose
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi

cat \
<#list sampleChunk as chnk>
${studyPedMapChrDir}/chr${chr}_sampleChunk${chnk}.ped \
</#list>
> ${imputationResultDir}/~chr${chr}.ped

#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chr${chr}.ped ${imputationResultDir}/chr${chr}.ped

	putFile ${imputationResultDir}/chr${chr}.ped
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi


#Create *.fam file from *.imputed.dose and original ped file

awk '{print $1}' ${imputationResultDir}/chunk${chrChunk}-chr${chr}.imputed.dose \
	| awk '{print $1,$2}' FS="->" OFS="_" > ${imputationResultDir}/chunk${chrChunk}-chr${chr}_fam_sample.txt

awk '{$7=$1"_"$2;print $7,$1,$2,$3,$4,$5,$6}' \
	${imputationResultDir}/chr${chr}.ped \
	> ${imputationResultDir}/chr${chr}.tmp.ped

awk ' FILENAME=="${imputationResultDir}/chr${chr}.tmp.ped" \
	{arr[$1]=$0; next} FILENAME=="${imputationResultDir}/chunk${chrChunk}-chr${chr}_fam_sample.txt"  \
	{print arr[$1]} ' ${imputationResultDir}/chr${chr}.tmp.ped \
	${imputationResultDir}/chunk${chrChunk}-chr${chr}_fam_sample.txt \
	| awk '{print $1,$2,$3,$4,$5,$6,$7}' \
	| awk '{
		if ($0 ~ /^[ ]*$/) { \
			print "ERROR: FamilyID_SampleID combination not found in original PED file! Exiting now!" > "/dev/stderr"; exit 1; \
		} \
		else { \
			print $2,$3,$4,$5,$6,$7} \
		}' \
	> ${imputationResultDir}/~chr${chr}.fam

#Get return code from last program call
returnCode=$?


if [ $returnCode -eq 0 ]
then

	mv ${imputationResultDir}/~chr${chr}.fam ${imputationResultDir}/chr${chr}.fam

	putFile ${imputationResultDir}/chr${chr}.fam
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi

