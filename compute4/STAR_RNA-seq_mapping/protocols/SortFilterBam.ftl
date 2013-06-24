#MOLGENIS walltime=6:00:00 nodes=1 cores=1 mem=4

${samtools} view -bS \
${outputDir}/Aligned.out.sam \
> ${outputDir}/Aligned.out.bam

${samtools} sort \
${outputDir}/Aligned.out.bam \
${outputDir}/Aligned.out.sorted

${samtools} index \
${outputDir}/Aligned.out.sorted.bam

rm ${outputDir}/Aligned.out.bam
rm ${outputDir}/Aligned.out.sam

