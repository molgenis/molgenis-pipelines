#MOLGENIS walltime=24:00:00 nodes=1 ppn=8 mem=40gb

#Parameter mapping
#string reads1FqGz
#string reads2FqGz
#string internalId
#string STARindex
#string starVersion
#string uniqueID
#string alignmentDir
#string twoPassMethod
#string unfilteredBamDir
#string outSAMmapqUnique

#Echo parameter values
fastq1="${reads1FqGz}"
fastq2="${reads2FqGz}"
prefix="${uniqueID}"
STARindex="${STARindex}"


#load modules JDK,STAR,PICARDTools
module load STAR/${starVersion}
module list

# something that can go easily wrong is that R1 and R2 have the same name
# (because R1 got written twice), so double check they are not the same
if [ "$reads1FqGz" == "$reads2FqGz" ];
then
    echo "ERROR: Reads1FqGz and reads2FqGz are the same"
    exit 1;
fi

echo -e "fastq1=${fastq1}\nfastq2=${fastq2}\nprefix=${prefix}\nSTARindex=${STARindex}"

mkdir -p ${alignmentDir}
mkdir -p ${unfilteredBamDir}

if [ ${#reads2FqGz} -eq 0 ]; then
    seqType="SR"
else
    seqType="PE"
fi

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
		--outFileNamePrefix ${TMPDIR}/${prefix}. \
		--readFilesIn ${fastq1} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism} \
		--twopassMode ${twoPassMethod} \
        --quantMode GeneCounts \
        --outSAMunmapped Within
# Option --outSAMmapqUnique is not necesarry anymore
# GatkSplitAndTrim automatically changes 255 to 60
# see https://gatkforums.broadinstitute.org/gatk/discussion/10800/gatk4-how-to-reassign-star-mapping-quality-from-255-to-60-with-splitncigarreads
# Leaving this commnet in for future reference why it is not included
	starReturnCode=$?

elif [ ${seqType} == "PE" ]
then
	echo "Mapping paired-end reads"
	let numMism=$numMism*2
	echo "Allowing $numMism mismatches"
	STAR \
		--outFileNamePrefix ${TMPDIR}/${prefix}. \
		--readFilesIn ${fastq1} ${fastq2} \
		--readFilesCommand zcat \
		--genomeDir ${STARindex} \
		--genomeLoad NoSharedMemory \
		--runThreadN 8 \
		--outFilterMultimapNmax 1 \
		--outFilterMismatchNmax ${numMism} \
		--twopassMode ${twoPassMethod} \
        --quantMode GeneCounts \
        --outSAMunmapped Within
# Option --outSAMmapqUnique is not necesarry anymore
# GatkSplitAndTrim automatically changes 255 to 60
# see https://gatkforums.broadinstitute.org/gatk/discussion/10800/gatk4-how-to-reassign-star-mapping-quality-from-255-to-60-with-splitncigarreads
# Think it was added in commit f26cb5dbd7f8bb4ee549c7c1c1044e8ec7a28645 of GATK
# Leaving this commnet in for future reference why it is not included
	starReturnCode=$?
else
	echo "Seqtype unknown"
	exit 1
fi

echo "STAR return code: ${starReturnCode}"

if [ $starReturnCode -eq 0 ]
then

	for tempFile in ${TMPDIR}/${prefix}* ; do
        # exclude dir as they are tmpoutput
        if [ ! -d "$tempFile" ];
        then
    		finalFile=$(basename $tempFile)
	    	echo "Moving temp file: ${tempFile} to ${alignmentDir}/${finalFile}"
    		mv $tempFile ${alignmentDir}/$finalFile
            cd ${alignmentDir}
            md5sum ${alignmentDir}/$finalFile > ${alignmentDir}/$finalFile.md5
            cd -
            # STAR appends some extra stuff to filename, which makes it not match with HISAT in next steps
            # therefore, rename it so that next steps can use same naming scheme
            if [[ ${alignmentDir}/$finalFile == *.sam ]];
            then
                mv ${alignmentDir}/$finalFile ${alignmentDir}/${uniqueID}.sam
            fi
        fi
	done
else
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi


