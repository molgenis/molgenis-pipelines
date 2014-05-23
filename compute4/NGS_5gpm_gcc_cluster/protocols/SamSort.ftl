
#MOLGENIS walltime=35:59:00 mem=4 cores=4
#TARGETS

module load picard-tools/1.61
module list

getFile ${bamfile}
alloutputsexist \
 "${sortedbam}" \
 "${sortedbamindex}"

java -jar -Xmx3g $PICARD_HOME/SortSam.jar \
INPUT=${bamfile} \
OUTPUT=${sortedbam} \
SORT_ORDER=coordinate \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=${tempdir}

java -jar -Xmx3g $PICARD_HOME/BuildBamIndex.jar \
INPUT=${sortedbam} \
OUTPUT=${sortedbamindex} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=${tempdir}

putFile ${sortedbam}
putFile ${sortedbamindex}
