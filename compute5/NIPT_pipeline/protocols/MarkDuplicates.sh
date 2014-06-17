#MOLGENIS walltime=23:59:00 mem=12gb nodes=1 ppn=8

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string markDuplicatesJar
#string sampleMergedBam
#string sampleMergedBamIdx
#string tempDir
#string intermediateDir
#string tmpDedupBam
#string tmpDedupBamIdx
#string dedupBam
#string dedupBamIdx
#string tmpDedupMetrics
#string dedupMetrics


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "markDuplicatesJar: ${markDuplicatesJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "tmpDedupBam: ${tmpDedupBam}"
echo "tmpDedupBamIdx: ${tmpDedupBamIdx}"
echo "dedupBam: ${dedupBam}"
echo "dedupBamIdx: ${dedupBamIdx}"
echo "tmpDedupMetrics: ${tmpDedupMetrics}"
echo "dedupMetrics: ${dedupMetrics}"


sleep 10

#Check if output exists
alloutputsexist \
"${dedupBam}" \
"${dedupBamIdx}"

#Get merged BAM file
getFile ${sampleMergedBam}
getFile ${sampleMergedBamIdx}
#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}

#Run picard, sort BAM file and create index on the fly
java -jar -Xmx4g $PICARD_HOME/${markDuplicatesJar} \
INPUT=${sampleMergedBam} \
METRICS_FILE=${tmpDedupMetrics} \
OUTPUT=${tmpDedupBam} \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR=${tempDir}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode MarkDuplicates: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpDedupBam} ${dedupBam}
    mv ${tmpDedupBamIdx} ${dedupBamIdx}
    mv ${tmpDedupMetrics} ${dedupMetrics}
    putFile "${dedupBam}"
    putFile "${dedupBamIdx}"
    putFile "${dedupMetrics}"
    
else
    echo -e "\nFailed to move MarkDuplicates results to ${intermediateDir}\n\n"
    exit -1
fi
