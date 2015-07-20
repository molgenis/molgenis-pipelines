#MOLGENIS walltime=23:59:00 mem=6gb nodes=1 ppn=4

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
#string addOrReplaceGroupsBam
#string addOrReplaceGroupsBai



echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
#getFile ${starAlignmentPassTwoDir}/Aligned.out.sam

${stage} picard-tools/${picardVersion}
${checkStage}

mkdir -p ${addOrReplaceGroupsDir}

echo "## "$(date)" Start $0"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar $PICARD_HOME/AddOrReplaceReadGroups.jar \
 INPUT=${starAlignmentPassTwoDir}/Aligned.out.sam \
 OUTPUT=${addOrReplaceGroupsBam} \
 SORT_ORDER=coordinate \
 RGID=${internalId} \
 RGLB=${sampleName}_${internalId} \
 RGPL=ILLUMINA \
 RGPU=${sampleName}_${internalId}_${internalId} \
 RGSM=${sampleName} \
 RGDT=$(date --rfc-3339=date) \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${addOrReplaceGroupsDir} \

then
 echo "returncode: $?"; 
#putFile ${addOrReplaceGroupsBam}
#putFile ${addOrReplaceGroupsBai}
 echo "md5sums"
 echo "${addOrReplaceGroupsBam} - " md5sum ${addOrReplaceGroupsBam}
 echo "${addOrReplaceGroupsBai} - " md5sum ${addOrReplaceGroupsBai}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
