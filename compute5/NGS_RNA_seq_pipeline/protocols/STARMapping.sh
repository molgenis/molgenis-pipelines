#MOLGENIS walltime=24:00:00 nodes=1 cores=8 mem=40gb

#Parameter mapping
#string leftbarcodefqgz
#string rightbarcodefqgz
#string intermediateDir
#string externalSampleID
#string STARindex
#string seqType

#Echo parameter values
fastq1="${leftbarcodefqgz}"
fastq2="${rightbarcodefqgz}"
outputFolder="${intermediateDir}"
prefix="${externalSampleID}"
STARindex="${STARindex}"
seqType="${seqType}"


#load modules JDK,STAR,PICARDTools
module load STAR/2.3.1l
module load picard-tools/1.102
module list

hostname

echo -e "fastq1=${fastq1}\nfastq2=${fastq2}\noutputFolder=${outputFolder}\nprefix=${prefix}\nSTARindex=${STARindex}"

mkdir -p ${outputFolder}

alloutputsexist ${outputFolder}/${prefix}Aligned.out.sorted.bam

# Check md5sum
if [ -a ${fastq1}.md5 ]
then
	cd `dirname ${fastq1}`
	echo "Checking fastq1 MD5 sum"
	if ! md5sum -c ${fastq1}.md5
	then
		echo "MD5 check for fastq1 failed"
		exit 1
	fi
	cd -
fi


#if [ ${#fastq2} -ne 0 -a -a ${fastq2}.md5 ]
if [ ${seqType} == "PE" ]
then
	cd `dirname ${fastq2}`
	echo "Checking fastq2 MD5 sum"
	if ! md5sum -c ${fastq2}.md5
	then
		echo "MD5 check for fastq2 failed"
		exit 1
	fi
	cd -
fi

inputs ${fastq1}

seq=`zcat ${fastq1} | head -2 | tail -1`
echo "seq used to determine read length: ${seq}"
readLength="${#seq}"

if [ $readLength -ge 90 ]; then
	numMism=4
elif [ $readLength -ge 60 ]; then
	numMism=3
else
	numMism=2
fi

echo "readLength=$readLength"



#if [ ${#fastq2} -eq 0 ]; 
if [ ${seqType} == "SR" ]
then

	echo "Mapping single-end reads"
	echo "Allowing $numMism mismatches"
	STAR \
		--outFileNamePrefix ${TMPDIR}/${prefix}___tmp___. \
		--readFilesIn ${fastq1} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism}

	starReturnCode=$?

elif [ ${seqType} == "PE" ]
then
	inputs ${fastq2}

	echo "Mapping paired-end reads"
	let numMism=$numMism*2
	echo "Allowing $numMism mismatches"
	STAR \
		--outFileNamePrefix ${TMPDIR}/${prefix}___tmp___. \
		--readFilesIn ${fastq1} ${fastq2} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism}
		
	starReturnCode=$?
else 
	echo "Seqtype unknown"
	exit 1
	
fi

echo "STAR return code: ${starReturnCode}"

if [ $starReturnCode -eq 0 ]
then

	for tempFile in ${TMPDIR}/${prefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi

java -Xmx40g -Xms40g -jar $PICARD_HOME/SortSam.jar I=${TMPDIR}/${prefix}.Aligned.out.sam O=${outputFolder}/${prefix}___tmp___.Aligned.out.sorted.bam SO=coordinate TMP_DIR=${TMPDIR} CREATE_MD5_FILE=false CREATE_INDEX=true 

returnCode=$?

echo "Picard return code: ${returnCode}"

if [ $returnCode -eq 0 ]
then

	for tempFile in ${outputFolder}/${prefix}___tmp___* ; do
		finalFile=`echo $tempFile | sed -e "s/___tmp___//g"`
		echo "Moving temp file: ${tempFile} to ${finalFile}"
		mv $tempFile $finalFile
	done

	cd $outputFolder
	md5sum $prefix.Aligned.out.sorted.bam > $finalFile.md5
	
	cp ${TMPDIR}/${prefix}.Log.out ${outputFolder}/${prefix}.Log.out
	cp ${TMPDIR}/${prefix}.Log.final.out ${outputFolder}/${prefix}.Log.final.out
	gzip -c ${TMPDIR}/${prefix}.SJ.out.tab > ${outputFolder}/${prefix}.SJ.out.tab.gz   
	
else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
	
fi
