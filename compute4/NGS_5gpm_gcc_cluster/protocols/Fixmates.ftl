
#MOLGENIS walltime=35:59:00 mem=6 nodes=1 cores=4

module load picard-tools/1.61
module list

inputs "${realignedbam}"
alloutputsexist \
 "${matefixedbam}" \
 "${matefixedbamindex}"

java -jar -Xmx6g $PICARD_HOME/FixMateInformation.jar \
INPUT=${realignedbam} \
OUTPUT=${matefixedbam} \
SORT_ORDER=coordinate \
VALIDATION_STRINGENCY=SILENT \
TMP_DIR=${tempdir}

java -jar -Xmx3g $PICARD_HOME/BuildBamIndex.jar \
INPUT=${matefixedbam} \
OUTPUT=${matefixedbamindex} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=1000000 \
TMP_DIR=${tempdir}
