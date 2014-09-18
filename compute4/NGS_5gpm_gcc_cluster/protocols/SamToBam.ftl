
#MOLGENIS walltime=35:59:00 mem=3 cores=4

module load picard-tools/1.61
module list

getFile ${samfile}
alloutputsexist "${bamfile}"

java -jar -Xmx3g $PICARD_HOME/SamFormatConverter.jar \
INPUT=${samfile} \
OUTPUT=${bamfile} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempdir}

putFile ${bamfile}
