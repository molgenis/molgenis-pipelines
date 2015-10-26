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
#string sambambaVersion

#Load Picard module
${stage} sambamba
${checkStage}

makeTmpDir ${dedupBam}
tmpDedupBam=${MC_tmpFile}

makeTmpDir ${dedupBamIdx}
tmpDedupBamIdx=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
${EBROOTSAMBAMBA}/${sambambaVersion} markdup \
--nthreads=4 \
--overflow-list-size 1000000 \
--hash-table-size 1000000 \
-p --tmpdir=${tempDir} \
${sampleMergedBam} ${tmpDedupBam}

echo -e "\nMarkDuplicates finished succesfull. Moving temp files to final.\n\n"
mv ${tmpDedupBam} ${dedupBam}
mv ${tmpDedupBamIdx} ${dedupBamIdx}

