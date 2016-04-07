#MOLGENIS walltime=23:59:00 mem=30gb ppn=5

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string sampleMergedBam
#string sampleMergedBamIdx
#string tempDir
#string dedupBam
#string dedupBamIdx
#string dedupMetrics
#string tmpDataDir
#string picardJar
#string sambambaVersion
#string sambambaTool
#string dedupMetrics
#string	project
#string logsDir
#string flagstatMetrics

#Load Picard module
${stage} ${sambambaVersion}
${checkStage}
sleep 5

makeTmpDir ${flagstatMetrics}
tmpFlagstatMetrics=${MC_tmpFile}

makeTmpDir ${dedupBam}
tmpDedupBam=${MC_tmpFile}

makeTmpDir ${dedupBamIdx}
tmpDedupBamIdx=${MC_tmpFile}

makeTmpDir ${dedupMetrics}
tmpDedupMetrics=${MC_tmpFile}


##Run picard, sort BAM file and create index on the fly
${EBROOTSAMBAMBA}/${sambambaTool} markdup \
--nthreads=4 \
--overflow-list-size 1000000 \
--hash-table-size 1000000 \
-p \
--tmpdir=${tempDir} \
${sampleMergedBam} ${tmpDedupBam}

#make metrics file
${EBROOTSAMBAMBA}/${sambambaTool} \
flagstat \
--nthreads=4 \
${tmpDedupBam} > ${tmpFlagstatMetrics}

echo -e "READ_PAIR_DUPLICATES\tPERCENT_DUPLICATION" > ${tmpDedupMetrics}
sed -n '1p;4p' ${tmpFlagstatMetrics} | awk '{print $1}' | perl -wpe 's|\n|\t|' | awk '{print $2"\t"($2/$1)*100}' >> ${tmpDedupMetrics}

echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
mv ${tmpFlagstatMetrics} ${flagstatMetrics}
echo "moved ${tmpFlagstatMetrics} ${flagstatMetrics}"
mv ${tmpDedupBam} ${dedupBam}
echo "moved ${tmpDedupBam} ${dedupBam}"
mv ${tmpDedupBamIdx} ${dedupBamIdx}
echo "mv ${tmpDedupBamIdx} ${dedupBamIdx}"
mv ${tmpDedupMetrics} ${dedupMetrics}
echo "mv ${tmpDedupMetrics} ${dedupMetrics}"
