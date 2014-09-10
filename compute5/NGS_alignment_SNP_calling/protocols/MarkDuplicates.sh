#MOLGENIS walltime=23:59:00 mem=4gb ppn=4

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string markDuplicatesJar
#string sampleMergedBam
#string sampleMergedBamIdx
#string tempDir
#string intermediateDir
#string dedupBam
#string dedupBamIdx
#string dedupMetrics

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "markDuplicatesJar: ${markDuplicatesJar}"
echo "sampleMergedBam: ${sampleMergedBam}"
echo "sampleMergedBamIdx: ${sampleMergedBamIdx}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "dedupBam: ${dedupBam}"
echo "dedupBamIdx: ${dedupBamIdx}"
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

makeTmpDir ${dedupBam}
tmpDedupBam=${MC_tmpFile}

makeTmpDir ${dedupBamIdx}
tmpDedupBamIdx=${MC_tmpFile}

makeTmpDir ${dedupMetrics}
tmpDedupMetrics=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx4g $PICARD_HOME/${markDuplicatesJar} \
INPUT=${sampleMergedBam} \
METRICS_FILE=${tmpDedupMetrics} \
OUTPUT=${tmpDedupBam} \
REMOVE_DUPLICATES=false \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR=${tempDir}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode MarkDuplicates: $returnCode\n\n"

echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
mv ${tmpDedupBam} ${dedupBam}
mv ${tmpDedupBamIdx} ${dedupBamIdx}
mv ${tmpDedupMetrics} ${dedupMetrics}
putFile "${dedupBam}"
putFile "${dedupBamIdx}"
putFile "${dedupMetrics}"
