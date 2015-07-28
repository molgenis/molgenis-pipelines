#MOLGENIS walltime=23:59:00 mem=3gb ppn=4

#string bed5GPM
#string baitBed
#string capturingKit
#string sortedBam
#string intervalsSortedBam
#string fileWithIndexId
#string sortSamJar
#string tempDir


module load samtools
module load picard-tools

if [ ${capturingKit} == "None" ]
then
	samtools view -b -h -L ${bed5GPM} \
	${sortedBam} > ${fileWithIndexId}.notsorted.intervals
else
	samtools view -b -h -L ${baitBed} \
        ${sortedBam} > ${fileWithIndexId}.notsorted.intervals
fi

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx3g $PICARD_HOME/${sortSamJar} \
INPUT=${fileWithIndexId}.notsorted.intervals \
OUTPUT=${intervalsSortedBam} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}

