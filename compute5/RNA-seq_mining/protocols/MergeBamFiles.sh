#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string intermediateDir

#string picardVersion
#string addOrReplaceGroupsDir
#list addOrReplaceGroupsBam
#list addOrReplaceGroupsBai

#string MergeBamFilesDir
#string MergeBamFilesBam
#string MergeBamFilesBai


alloutputsexist \
"${MergeBamFilesBam}" \
"${MergeBamFilesBai}"

echo "## "$(date)" ##  $0 Started "

for file in "${addOrReplaceGroupsBam[@]}" "${addOrReplaceGroupsBai[@]}"; do
	echo "getFile file='$file'"
	getFile $file
done

#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}

#${addOrReplaceGroupsBam} sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${addOrReplaceGroupsBam[@]}" | sort -u ))
inputs=$(printf 'INPUT=%s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${MergeBamFilesDir}

java -jar -Xmx6g $PICARD_HOME/MergeSamFiles.jar \
 $inputs \
 SORT_ORDER=coordinate \
 CREATE_INDEX=true \
 USE_THREADING=true \
 TMP_DIR=${MergeBamFilesDir} \
 MAX_RECORDS_IN_RAM=6000000 \
 OUTPUT=${MergeBamFilesBam} \

# VALIDATION_STRINGENCY=LENIENT \

putFile ${MergeBamFilesBam}
putFile ${MergeBamFilesBai}

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
