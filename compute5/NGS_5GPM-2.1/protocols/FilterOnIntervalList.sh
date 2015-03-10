#MOLGENIS walltime=23:59:00 mem=3gb ppn=4

#string baitBed
#string intervalsSortedBam
#string fileWithIndexId
#string sortSamJar


module load samtools
module load picard-tools

samtools view -b -h -L ${baitBed} \
${sortedBam} > ${fileWithIndexId}.notsorted.intervals


#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx3g $PICARD_HOME/${sortSamJar} \
INPUT=${fileWithIndexId}.notsorted.intervals \
OUTPUT=${intervalsSortedBam}.bam \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}

