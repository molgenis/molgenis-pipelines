#MOLGENIS walltime=48:00:00 nodes=1 cores=1 mem=4

outputFolder=${outputFolder}
outputPrefix=${outputPrefix}
samtools=${samtools}

<#noparse>



alloutputsexist \
	${outputFolder}/${outputPrefix}Aligned.out.sorted.bam \
	${outputFolder}/${outputPrefix}Aligned.out.sorted.bam.bai

inputs ${outputFolder}/${outputPrefix}Aligned.out.sam

${samtools} view -bS \
	${outputFolder}/${outputPrefix}Aligned.out.sam \
	> ${outputFolder}/${outputPrefix}Aligned.out.bam

returnCode=$?

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi

echo "conversion to bam complete" 

${samtools} sort \
	${outputFolder}/${outputPrefix}Aligned.out.bam \
	${outputFolder}/${outputPrefix}___tmp___Aligned.out.sorted

returnCode=$?

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi

echo "bam file sorted"

${samtools} index \
	${outputFolder}/${outputPrefix}___tmp___Aligned.out.sorted.bam

returnCode=$?

if [ $returnCode -eq 0 ]
then

	for tempFile in ${outputFolder}/${outputPrefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


rm ${outputFolder}/${outputPrefix}Aligned.out.bam
rm ${outputFolder}/${outputPrefix}Aligned.out.sam


</#noparse>