#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage

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



${stage} picard/${picardVersion}
${checkStage}

mkdir -p ${markDuplicatesDir}

java -Xmx6g -XX:ParallelGCThreads=8 -jar $EBROOTPICARD/MarkDuplicates.jar \
 INPUT=${mergeBamFilesBam} \
 OUTPUT=${markDuplicatesBam} \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${markDuplicatesDir} \
 METRICS_FILE=${markDuplicatesMetrics}

echo "returncode: $?";

cd ${markDuplicatesDir}
md5sum ${markDuplicatesMetrics} > ${markDuplicatesMetrics}.md5
cd -

echo "## "$(date)" ##  $0 Done "
