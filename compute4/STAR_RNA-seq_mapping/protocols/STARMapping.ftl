#MOLGENIS walltime=6:00:00 nodes=1 cores=8 mem=30

fastq1="${fastq1}"
fastq2="${fastq2}"
outputFolder="${outputFolder}"
prefix="${outputPrefix}"
STAR="${STAR}"
STARindex="${STARindex}"

<#noparse>

echo -e "fastq1=${fastq1}\nfastq2=${fastq2}\noutputFolder=${outputFolder}\nprefix=${prefix}\nSTAR=${STAR}\nSTARindex=${STARindex}"

mkdir -p ${outputFolder}

alloutputsexist ${outputFolder}/${prefix}Aligned.out.sam


#Output of this step is removed at the end of next step. Only run this step if output of next step is not present
if [ -f ${outputFolder}/${outputPrefix}Aligned.out.sorted.bam ] && [ -f ${outputFolder}/${outputPrefix}Aligned.out.sorted.bam.bai ]
then

	echo "skipping"
	exit 0

fi

inputs ${fastq1}

seq=`head -2 ${fastq1} | tail -1`
readLength="${#seq}"

if [ $readLength -ge 90 ]; then
	numMism=4
elif [ $readLength -ge 60 ]; then
	numMism=3
else
	numMism=2
fi

echo "readLength=$readLength"



if [ ${#fastq2} -eq 0 ]; 
then

	echo "Mapping single-end reads"
	echo "Allowing $numMism mismatches"
	${STAR} \
		--outFileNamePrefix ${outputFolder}/${prefix}___tmp___ \
		--readFilesIn ${fastq1} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism}

	starReturnCode=$?

else

	inputs ${fastq2}

	echo "Mapping paired-end reads"
	let numMism=$numMism*2
	echo "Allowing $numMism mismatches"
	${STAR} \
		--outFileNamePrefix ${outputFolder}/${prefix}___tmp___ \
		--readFilesIn ${fastq1} ${fastq2} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism}
		
	starReturnCode=$?
	
fi

echo "STAR return code: ${starReturnCode}"

if [ $starReturnCode -eq 0 ]
then

	for tempFile in ${outputFolder}/${prefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi


</#noparse>
