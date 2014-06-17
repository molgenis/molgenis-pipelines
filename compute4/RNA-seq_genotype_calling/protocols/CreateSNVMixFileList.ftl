#MOLGENIS walltime=1:00:00 nodes=1 cores=1 mem=4

#FOREACH mergedStudy

genotypeFolder="${genotypeFolder}"
JAVA_HOME="${JAVA_HOME}"

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
	
	if [ -f ${snvmixOuts[$i]} ]
	then
		echo -e  "${samples[$i]}\t${snvmixOuts[$i]}" >> ${genotypeFolder}/fileList.txt
	else
		echo "Skipping sample ${samples[$i]} no snvmix output"
	fi
	
	
done

</#noparse>
