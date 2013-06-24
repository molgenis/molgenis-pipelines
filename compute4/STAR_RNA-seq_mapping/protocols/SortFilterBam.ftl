#MOLGENIS walltime=6:00:00 nodes=1 cores=1 mem=4

${samtools} view -bS \
${outputFolder}/Aligned.out.sam \
> ${outputFolder}/Aligned.out.bam

${samtools} sort \
${outputFolder}/Aligned.out.bam \
${outputFolder}/Aligned.out.sorted

${samtools} index \
${outputFolder}/Aligned.out.sorted.bam

rm ${outputFolder}/Aligned.out.bam
rm ${outputFolder}/Aligned.out.sam

