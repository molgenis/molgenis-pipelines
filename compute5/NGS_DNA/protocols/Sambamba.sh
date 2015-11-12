#MOLGENIS walltime=23:59:00 mem=20gb ppn=5

#Parameter mapping
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

#Load Picard module
${stage} ${sambambaVersion}
${checkStage}
sleep 5

makeTmpDir ${dedupBam}
tmpDedupBam=${MC_tmpFile}

makeTmpDir ${dedupBamIdx}
tmpDedupBamIdx=${MC_tmpFile}

makeTmpDir ${dedupMetrics}
tmpDedupMetrics=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
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
${tmpDedupBam} > ${tmpDedupBam}.flagstat

echo -e "READ PAIR DUPLICATES\tPERCENTAGE DUPLICATES" > ${tmpDedupMetrics}
sed -n '1p;4p' ${tmpDedupBam}.flagstat | awk '{print $1}' | perl -wpe 's|\n|\t|' | awk '{print $2"\t"($2/$1)*100}' >> ${tmpDedupMetrics}

echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
mv ${tmpDedupBam} ${dedupBam}
mv ${tmpDedupBamIdx} ${dedupBamIdx}
echo "moved ${tmpDedupBam} ${dedupBam}"
echo "mv ${tmpDedupBamIdx} ${dedupBamIdx}"


mv ${tmpDedupMetrics} ${dedupMetrics}
echo "mv ${tmpDedupMetrics} ${dedupMetrics}"
