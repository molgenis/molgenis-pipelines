#MOLGENIS walltime=23:59:00 mem=6gb nodes=1 ppn=8

#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir
#string picardVersion
#string sampleName
#string internalId
#string addOrReplaceGroupsDir
#string addOrReplaceGroupsBam
#string addOrReplaceGroupsBai
#string sortedBamFile
#string toolDir
#string readQuality
#string uniqueID

echo "## "$(date)" ##  $0 Started "

getFile ${sortedBamFile}

${stage} picard/${picardVersion}
${checkStage}

mkdir -p ${addOrReplaceGroupsDir}

echo "## "$(date)" Start $0"

if java -Xmx6g -XX:ParallelGCThreads=8 -jar ${toolDir}picard/${picardVersion}/AddOrReplaceReadGroups.jar \
 INPUT=${sortedBamFile} \
 OUTPUT=${addOrReplaceGroupsBam} \
 SORT_ORDER=coordinate \
 RGID=${internalId} \
 RGLB=${uniqueID} \
 RGPL=ILLUMINA \
 RGPU=${sampleName}_${internalId}_${internalId} \
 RGSM=${sampleName} \
 RGDT=$(date --rfc-3339=date) \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${addOrReplaceGroupsDir} \

then
 echo "returncode: $?"; 

 putFile ${addOrReplaceGroupsBam}
 putFile ${addOrReplaceGroupsBai}

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "



echo "## "$(date)" ##  $0 Done "
