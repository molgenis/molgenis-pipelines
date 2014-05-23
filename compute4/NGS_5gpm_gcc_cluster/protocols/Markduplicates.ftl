
#MOLGENIS walltime=35:59:00 mem=4 nodes=1 cores=8

module load picard-tools/1.61
module list

inputs "${sortedbam}"
inputs "${sortedbamindex}"
alloutputsexist \
 "${dedupbam}" \
 "${dedupmetrics}" \
 "${dedupbamindex}"

java -Xmx4g -jar $PICARD_HOME/MarkDuplicates.jar \
INPUT=${sortedbam} \
OUTPUT=${dedupbam} \
METRICS_FILE=${dedupmetrics} \
REMOVE_DUPLICATES=false \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${tempdir}

java -jar -Xmx3g $PICARD_HOME/BuildBamIndex.jar \
INPUT=${dedupbam} \
OUTPUT=${dedupbamindex} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=${tempdir}
