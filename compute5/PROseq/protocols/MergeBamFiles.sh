#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string WORKDIR
#string projectDir
#string picardVersion
#string addOrReplaceGroupsDir
#list addOrReplaceGroupsBam, addOrReplaceGroupsBai
#string mergeBamFilesDir
#string mergeBamFilesBam
#string mergeBamFilesBai



echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

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

mkdir -p ${mergeBamFilesDir}

if java -jar -XX:ParallelGCThreads=4 -Xmx6g $PICARD_HOME/MergeSamFiles.jar \
 $inputs \
 SORT_ORDER=coordinate \
 CREATE_INDEX=true \
 USE_THREADING=true \
 TMP_DIR=${mergeBamFilesDir} \
 MAX_RECORDS_IN_RAM=6000000 \
 OUTPUT=${mergeBamFilesBam} \

# VALIDATION_STRINGENCY=LENIENT \

then
 echo "returncode: $?"; 

 putFile ${mergeBamFilesBam}
 putFile ${mergeBamFilesBai}
 echo "md5sums"
 echo "${mergeBamFilesBam} - " md5sum ${mergeBamFilesBam}
 echo "${mergeBamFilesBai} - " md5sum ${mergeBamFilesBai}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
