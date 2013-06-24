#MOLGENIS walltime=5:00:00 nodes=1 cores=8 mem=16

fastq1="${fastq1}"
fastq2="${fastq2}"
outputFolder="${outputFolder}"
STAR="${STAR}"
STARindex="${STARindex}"

<#noparse>

echo -e "fastq1=${fastq1}\nfastq2=${fastq2}\noutputFolder=${outputFolder}\nSTAR=${STAR}\nSTARindex=${STARindex}"

mkdir -p ${outputFolder}

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

if [ ${#fastq} -eq 0 ]; then

echo "Mapping single-end reads"
echo "Allowing $numMism mismatches"
${STAR} \
--outFileNamePrefix ${outputFolder} \
--readFilesIn ${fastq1} \
--readFilesCommand zcat \
--genomeDir ${STARindex} \
--genomeLoad NoSharedMemory \
--runThreadN 8 \
--outFilterMultimapNmax 1 \
--outFilterMismatchNmax ${numMism}

else
echo "Mapping paired-end reads"
let numMism=$numMism*2
echo "Allowing $numMism mismatches"
${STAR} \
--outFileNamePrefix ${sampleFolder} \
--readFilesIn ${fastq1} ${fastq2} \
--readFilesCommand zcat \
--genomeDir ${STARindex} \
--genomeLoad NoSharedMemory \
--runThreadN 8 \
--outFilterMultimapNmax 1 \
--outFilterMismatchNmax ${numMism} \
fi

</#noparse>
