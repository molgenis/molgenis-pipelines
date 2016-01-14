#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string sampleMergedBam
#string sampleMergedBai
#string sampleMergedDedupBam
#string sampleMergedDedupBai
#string dupStatMetrics
#string tempDir
#string tmpDataDir
#string project
#string intermediateDir
#string picardJar
#string project

sleep 5

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

makeTmpDir ${sampleMergedDedupBam}
tmpSampleMergedDedupBam=${MC_tmpFile}

makeTmpDir ${sampleMergedDedupBai}
tmpSampleMergedDedupBai=${MC_tmpFile}

module load picard


#Duplicates statistics.
java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} MarkDuplicates \
I=${sampleMergedBam} \
O=${tmpSampleMergedDedupBam} \
CREATE_INDEX=true \
M=${dupStatMetrics} AS=true

mv ${tmpSampleMergedDedupBam} ${sampleMergedDedupBam}
mv ${tmpSampleMergedDedupBai} ${sampleMergedDedupBai}
