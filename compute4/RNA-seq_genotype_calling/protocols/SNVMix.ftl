#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=4


#FOREACH mergedStudy,sample

declare -a sortedBams=(${ssvQuoted(sortedBam)})
SNVMix="${SNVMix}"
samtools="${samtools}"
snpList="${snpList}"
faFile="${faFile}"
mergedBam="${mergedBam}"
snvmixOut="${snvmixOut}"
mpileupFile="${mpileupFile}"

<#noparse>


echo -e "SNVMix=${SNVMix}\nsnpList=${snpList}\nfaFile=${faFile}\nmergedBam=${mergedBam}\nmpileupFile=${mpileupFile}\n"

echo "snvmixOutput=${snvmixOut}"

alloutputsexist $snvmixOut

echo "bams: ${sortedBams[@]}"

echo "Number of runs: ${#sortedBams[@]}"

rm -f ${mergedBam}

#check if more than one run
if [ "${#sortedBams[@]}" -gt "1" ]
then

	samtools merge -r ${mergedBam} ${sortedBams[@]}
	
	returnCode=$?
	
	if [ $returnCode -ne 0 ]
	then
		echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
		#Return non zero return code
		exit 1
	fi

	echo "bam files merged"
	
else 

	 ln -s ${sortedBams[0]} ${mergedBam}
	 
	 echo "created symlink for the single bam file to be on same location as merged bam"
	
fi



echo "Writing mpileup output to $mpileupFile"

${samtools} mpileup \
	-A -B -Q 0 -s -d10000000 \
	-l ${snpList} \
	-f ${faFile} \
	${mergedBam} \
	> $mpileupFile

returnCode=$?

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi

echo "Writing SNVMix output to $snvmixOut"

${SNVMix} \
	-i $mpileupFile \
	-o ${snvmixOut}___tmp___

returnCode=$?

echo "return code snvMix ${returnCode}"


count=`cut -f 1 -d ":" ${snvmixOut}___tmp___ | uniq | wc -l`

if [ $count -ge 22 ]
then
	
	echo "Moving temp file: ${snvmixOut}___tmp___ to $snvmixOut"
	mv ${snvmixOut}___tmp___ $snvmixOut
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi

rm -f ${mergedBam}
rm ${mpileupFile}

</#noparse>