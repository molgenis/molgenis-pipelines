#MOLGENIS walltime=23:59:00 mem=6gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string starVersion
#string WORKDIR
#string projectDir

#string picardVersion

#string mergeBamFilesBam
#string mergeBamFilesBai

#string markDuplicatesDir
#string markDuplicatesBam
#string markDuplicatesBai
#string markDuplicatesMetrics
#string toolDir

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

getFile ${mergeBamFilesBam}
getFile ${mergeBamFilesBai}

${stage} picard/${picardVersion}
${checkStage}

mkdir -p ${markDuplicatesDir}

if java -Xmx6g -XX:ParallelGCThreads=8 -jar ${toolDir}picard/${picardVersion}/MarkDuplicates.jar \
 INPUT=${mergeBamFilesBam} \
 OUTPUT=${markDuplicatesBam} \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${markDuplicatesDir} \
 METRICS_FILE=${markDuplicatesMetrics}
then
 echo "returncode: $?"; 
 putFile ${markDuplicatesBam}
 putFile ${markDuplicatesBai}
 putFile ${markDuplicatesMetrics}
cd ${markDuplicatesDir}
 md5sum ${markDuplicatesMetrics} > ${markDuplicatesMetrics}.md5
cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
