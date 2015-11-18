#MOLGENIS walltime=23:59:00 mem=2gb ppn=2

#string dedupBam
#string indexFile
#string dedupCramBam

makeTmpDir ${dedupCramBam}
tmpDedupCramBam=${MC_tmpFile}

time java -jar /groups/umcg-gaf/tmp04/umcg-rkanninga/cramtools/cramtools-3.0.jar cram \
--input-bam-file ${dedupBam} \
--reference-fasta-file ${indexFile} \
--output-cram-file ${tmpDedupCramBam}
echo "$i to cram done"


time java -jar /groups/umcg-gaf/tmp04/umcg-rkanninga/cramtools/cramtools-3.0.jar bam \
--input-cram-file ${tmpDedupCramBam} \
--reference-fasta-file ${indexFile} \
--output-bam-file ${dedupCramBam}.backTo.bam
echo "$i back to bam done"

done

mv ${tmpDedupCramBam} ${dedupCramBam}
