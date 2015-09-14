#MOLGENIS walltime=23:59:00 mem=6gb ppn=6

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string markDuplicatesJar
#string sampleMergedBam
#string sampleMergedBamIdx
#string tempDir
#string dedupBam
#string dedupBamIdx
#string dedupMetrics
#string tmpDataDir
#string picardJar

#Load Picard module
${stage} ${picardVersion}
${checkStage}

makeTmpDir ${dedupBam}
tmpDedupBam=${MC_tmpFile}

makeTmpDir ${dedupBamIdx}
tmpDedupBamIdx=${MC_tmpFile}

makeTmpDir ${dedupMetrics}
tmpDedupMetrics=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx4g ${EBROOTPICARD}/${picardJar} ${markDuplicatesJar} \
INPUT=${sampleMergedBam} \
METRICS_FILE=${tmpDedupMetrics} \
OUTPUT=${tmpDedupBam} \
REMOVE_DUPLICATES=false \
CREATE_INDEX=true \
CREATE_MD5_FILE=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=4000000 \
TMP_DIR=${tempDir}

echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
mv ${tmpDedupBam} ${dedupBam}
mv ${tmpDedupBamIdx} ${dedupBamIdx}
mv ${tmpDedupMetrics} ${dedupMetrics}

