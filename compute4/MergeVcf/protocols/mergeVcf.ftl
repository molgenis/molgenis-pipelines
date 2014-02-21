#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

#FOREACH mergedVcf

mergedVcf="${mergedVcf}"
inputVcf="${inputVcf}"

<#noparse>

inputVcfFiles=($(cat ${inputVcf}))

for vcfFile in "${chunkFileLines[@]}"
do

	echo ${vcfFile}

done

echo "Merged vcf: ${mergedVcf}"



</#noparse>