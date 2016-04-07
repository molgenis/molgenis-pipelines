#MOLGENIS walltime=23:59:00 mem=4gb ppn=4
#string tmpName
#string capturedBed
#string sortedBam
#string intervalsSortedBam
#string fileWithIndexId
#string sortSamJar
#string intermediateDir
#string picardJar
#string picardVersion
#string samtoolsVersion
#string	project
#string logsDir

module load ${samtoolsVersion}
module load ${picardVersion}

samtools view -b -h -L ${capturedBed} \
${sortedBam} > ${fileWithIndexId}.notsorted.intervals

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx3g ${EBROOTPICARD}/${picardJar} ${sortSamJar} \
INPUT=${fileWithIndexId}.notsorted.intervals \
OUTPUT=${intervalsSortedBam}.bam \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}


