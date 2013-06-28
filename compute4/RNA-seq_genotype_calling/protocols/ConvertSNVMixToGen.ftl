#MOLGENIS walltime=10:00:00 nodes=1 cores=1 mem=4

#FOREACH mergedStudy

genotypeFolder="${genotypeFolder}"
shapeitBin="${shapeitBin}"

declare -a samples=(${ssvQuoted(sample)})
declare -a snvmixOuts=(${ssvQuoted(snvmixOut)})
<#noparse>

mkdir -p ${genotypeFolder}

echo "genotypeFolder=${genotypeFolder}"
echo "snvMixOuts=${snvmixOuts[*]}"
echo "samples=${samples[*]}"

rm -f ${genotypeFolder}/fileList.txt



declare -a samplesProcessed=()

for (( i = 0 ; i < ${#samples[@]} ; i++ )) 
do

	for processedSample in ${samplesProcessed[@]}
	do
		if [ $processedSample == ${samples[$i]} ]
		then
			continue 2
		fi
	done

	samplesProcessed=("${samplesProcessed[@]}" "${samples[$i]}")
	echo -e "sample:${samples[$i]}\tgenotype file:${snvmixOuts[$i]}"
	echo -e  "${samples[$i]}\t${snvmixOuts[$i]}" >> ${genotypeFolder}/fileList.txt
done


/cm/shared/apps/sunjdk/jdk1.6.0_21/bin/java \
        -Xmx4g \
        -jar /target/gpfs2/gcc/home/dasha/scripts/genotyping/GenotypeCalling/dist/GenotypeCalling.jar \
        --mode SNVMixToGen \
        --fileList ${genotypeFolder}/fileList.txt \
        --p-value 0.8 \
        --out ${genotypeFolder}/___tmp___chr

returnCode=$?
echo "Return code ${returnCode}"

if [ "${returnCode}" -eq "0" ]
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
echo "Filtering in ${genPath}"
for genFile in $genPath
do	
	if [[ "$genFile" != *sorted* ]]; then
	
		echo "------"
		echo "Sortingen and filtering: ${genFile}"
	
		sampleFile=${genotypeFolder}/chr.sample
		
		tmp=${genFile##*chr}
		chr=${tmp//.gen/}
		
		genFileSorted=${genFile//.gen/.sorted.gen}
	
		
		sort -k3,3n ${genFile} > ${genFileSorted}
			
		genFileSortedFiltered=${genFile//.gen/_CR0.8_maf0.01.gen}
	
		/target/gpfs2/gcc/tools/qctool/qctool_v1.3-linux-x86_64/qctool \
		-g $genFile \
		-s ${sampleFile} \
		-og ${genFileSortedFiltered} \
		-maf 0.01 1 \
		-hwe 4 \
		-snp-missing-rate 0.8 \
		-omit-chromosome 
		
		rm ${genFileSorted}
		rm ${genFile}
	fi
	
done



</#noparse>
