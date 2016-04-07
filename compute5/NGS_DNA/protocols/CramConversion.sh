#MOLGENIS walltime=23:59:00 mem=1gb ppn=9
#string tmpName
#string dedupBam
#string indexFile
#string dedupBamCram
#string dedupBamCramBam
#string indexFile
#string	project
#string logsDir

module load io_lib
module list

makeTmpDir ${dedupBamCram}
tmpDedupBamCram=${MC_tmpFile}

makeTmpDir ${dedupBamCramBam}
tmpDedupBamCramBam=${MC_tmpFile}

scramble \
-I bam \
-O cram \
-r ${indexFile} \
-m \
-t 8 \
${dedupBam} \
${tmpDedupBamCram}

scramble \
-I cram \
-O bam \
-r ${indexFile} \
-m \
-t 8 \
${tmpDedupBamCram} \
${tmpDedupBamCramBam}

echo "dirname"
mv ${tmpDedupBamCram} ${dedupBamCram}
mv ${tmpDedupBamCramBam} ${dedupBamCramBam} 
