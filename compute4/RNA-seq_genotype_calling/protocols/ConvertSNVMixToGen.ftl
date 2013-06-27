#MOLGENIS walltime=10:00:00 nodes=1 cores=1 mem=4

#FOREACH mergedStudy

genotypeFolder="${genotypeFolder}"
mergedBam="${mergedBam}"
declare -a samples=(${ssvQuoted(sample)})

<#noparse>
snvmixFile=${mergedBam//bam/mpileup}.snvmix
mkdir -p ${genotypeFolder}

echo -e "genotypeFolder=${genotypeFolder}\nsnvmix file=${snvmixOut}"


rm -f ${genotypeFolder}/fileList.txt

for (( i = 0 ; i < ${#samples[@]} ; i++ )) 
do
	cat "${sample[$i]}\t${snvmixFile[$i]}" >> ${genotypeFolder}/fileList.txt
done


/cm/shared/apps/sunjdk/jdk1.6.0_21/bin/java \
        Xmx4g \
        -jar /target/gpfs2/gcc/home/dasha/scripts/genotyping/GenotypeCalling/dist/GenotypeCalling.jar \
        --mode SNVMixToGen \
        --fileList ${genotypeFolder}/fileList.txt \
        --p-value 0.8 \
        --out ${genotypeFolder}/___tmp___chr


if [ $returnCode -eq 0 ]
then
	
	echo "Moving temp files: ${genotypeFolder}/___tmp___chr* to ${genotypeFolder}/chr*"
	tmpFiles="${genotypeFolder}/___tmp___chr*"
	for f in $tmpFiles
	do
		mv $f ${f//___tmp___/}
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


#Filtering and sorting
genPath=${genotypeFolder}/chr*.gen

for genFile in $genPath
do
	sampleFile=${genFile//gen/sample}
	if [[ "$genFile" != *sorted* ]]; then
		/target/gpfs2/gcc/tools/qctool/qctool_v1.3-linux-x86_64/qctool \
		-g $genFile \
		-s ${sampleFile} \
		-og ${genFile//.gen/_CR0.8_maf0.01.gen} \
		-maf 0.01 1 \
		-hwe 4 \
		-snp-missing-rate 0.8 \
		-omit-chromosome

		sort -k3,3n ${genFile//.gen/_CR0.8_maf0.01.gen} > ${genFile//.gen/_CR0.8_maf0.01.sorted.gen}
		rm ${genFile//.gen/_CR0.8_maf0.01.gen}
	fi
done

</#noparse>