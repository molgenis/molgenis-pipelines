#MOLGENIS walltime=24:00:00 nodes=1 cores=40 mem=100

#FOREACH mergedStudy


mergedFolder="${mergedFolder}"
prepareVcfJar="${prepareVcfJar}"
beagleWindow="${beagleWindow}"
refInfoFolder="${refInfoFolder}"
tabix="${tabix}"
bgzip="${bgzip}"
bcftools="${bcftools}"

samples=()

<#assign sampleSize=sample?size - 1>
<#list 0..sampleSize as i>
  samples+=('${sample[i]}')
</#list> 

<#noparse>

echo "Merged folder ${mergedFolder}"

for chr in {1..22}
do

	

	filesToMerge=()
	for sample in "${samples[@]}"
	do
	
		filesToMerge+=(${mergedFolder}/tmp/${sample}//chr${chr}.vcf.gz)
	
	done
	
	echo ${filesToMerge[@]}
	
	${bcftools} \
		merge \
		${filesToMerge[@]} \
		| ${bgzip} > ${mergedFolder}/chr${chr}.vcf.gz
		
	${tabix} -p vcf ${mergedFolder}/chr${chr}.vcf.gz

done

</#noparse>
