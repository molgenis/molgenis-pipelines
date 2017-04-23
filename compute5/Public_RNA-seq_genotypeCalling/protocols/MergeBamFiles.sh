#MOLGENIS walltime=23:59:00 mem=8gb ppn=4

### variables to help adding to database (have to use weave)
#string project
#string sampleName
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string picardVersion
#string addOrReplaceGroupsDir
#list addOrReplaceGroupsBam
#string mergeBamFilesDir
#string mergeBamFilesBam
#string mergeBamFilesBai
#string toolDir


echo "## "$(date)" Start $0"

#Load Picard module
${stage} picard/${picardVersion}
${checkStage}

set -o posix

#${addOrReplaceGroupsBam} sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${addOrReplaceGroupsBam[@]}" | sort -u ))
inputs=$(printf 'INPUT=%s ' $(printf '%s\n' ${bams[@]}))

mkdir -p ${mergeBamFilesDir}

if java -jar -XX:ParallelGCThreads=4 -Xmx6g $EBROOTPICARD/MergeSamFiles.jar \
 $inputs \
 SORT_ORDER=coordinate \
 CREATE_INDEX=true \
 USE_THREADING=true \
 TMP_DIR=${TMPDIR} \
 MAX_RECORDS_IN_RAM=6000000 \
 OUTPUT=${mergeBamFilesBam} \

# VALIDATION_STRINGENCY=LENIENT \

then
 echo "returncode: $?"; 

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
