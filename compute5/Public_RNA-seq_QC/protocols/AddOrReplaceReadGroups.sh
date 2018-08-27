#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

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
#string sortedBam
#string toolDir
#string uniqueID

echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

${stage} picard/${picardVersion}
${checkStage}


echo "## "$(date)" Start $0"

tmpBam=$TMPDIR/$(basename ${sortedBam})

if java -Xmx6g -XX:ParallelGCThreads=8 -jar $EBROOTPICARD/AddOrReplaceReadGroups.jar \
 INPUT=${sortedBam} \
 OUTPUT=$tmpBam \
 SORT_ORDER=coordinate \
 RGID=${internalId} \
 RGLB=${uniqueID} \
 RGPL=ILLUMINA \
 RGPU=${sampleName}_${internalId}_${internalId} \
 RGSM=${sampleName} \
 RGDT=$(date --rfc-3339=date) \
 CREATE_INDEX=true \
 MAX_RECORDS_IN_RAM=4000000 \
 TMP_DIR=${TMPDIR}

returnCode=$?
echo "returncode: $returnCode";

if [ $returnCode -eq 0 ]
then
    mv $tmpBam ${sortedBam}
else
    echo "fail!"
    exit 1;
fi

echo "## "$(date)" ##  $0 Done "

