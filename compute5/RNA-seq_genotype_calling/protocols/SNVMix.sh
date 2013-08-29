#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=4


#FOREACH mergedStudy,sample

#Parameter mapping
#string sortedBams
#string samtools
#string mpileupOptions
#string snpList
#string faFile
#string mergedBam
#string mpileupFile
#string SNVMix
#output snvmixOut

#Echo parameter values
echo -e "SNVMix=${SNVMix}\nsnpList=${snpList}\nfaFile=${faFile}\nmergedBam=${mergedBam}\nmpileupFile=${mpileupFile}\n"
echo "samtools: ${samtools}"
echo "mpileupOptions: ${mpileupOptions}"
echo "SNVMix: ${SNVMix}"
echo "snvmixOutput=${snvmixOut}"

#Check if output exists
alloutputsexist ${snvmixOut}

echo "sortedBams: ${sortedBams[@]}"

echo "Number of runs: ${#sortedBams[@]}"

rm -f ${mergedBam}

#Check if more than one run
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



echo "Writing mpileup output to ${mpileupFile}"

#Run Samtools mpileup on merged BAM
${samtools} mpileup \
	${mpileupOptions} \
	-l ${snpList} \
	-f ${faFile} \
	${mergedBam} \
	> ${mpileupFile}

returnCode=$?

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi

echo "Writing SNVMix output to $snvmixOut"

#Run SNVMix on generated mpileupFile
${SNVMix} \
	-i ${mpileupFile} \
	-o ${snvmixOut}___tmp___

returnCode=$?

echo "return code snvMix ${returnCode}"

if [ $returnCode -eq 0 ]
then
	
	echo "Moving temp file: ${snvmixOut}___tmp___ to $snvmixOut"
	mv ${snvmixOut}___tmp___ $snvmixOut
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi

#Remove intermediate files
rm -f ${mergedBam}
rm ${mpileupFile}
