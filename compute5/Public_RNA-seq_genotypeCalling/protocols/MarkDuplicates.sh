#MOLGENIS walltime=23:59:00 mem=6gb nodes=1 ppn=4

#Parameter mapping  #why not string foo,bar? instead of string foo\nstring bar
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


echo "## "$(date)" ##  $0 Started "


getFile ${mergeBamFilesBam}
getFile ${mergeBamFilesBai}

${stage} picard-tools/${picardVersion}
${checkStage}

set -x
set -e

mkdir -p ${markDuplicatesDir}

if java -Xmx6g -XX:ParallelGCThreads=4 -jar $PICARD_HOME/MarkDuplicates.jar \
 INPUT=${mergeBamFilesBam} \
 OUTPUT=${markDuplicatesBam} \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${markDuplicatesDir} \
 METRICS_FILE=${markDuplicatesMetrics}

#REMOVE_DUPLICATES=true \?

then
 echo "returncode: $?"; 

 putFile ${markDuplicatesBam}
 putFile ${markDuplicatesBai}
 putFile ${markDuplicatesMetrics}

 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
