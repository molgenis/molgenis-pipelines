#MOLGENIS walltime=6:00:00 nodes=1 cores=1 mem=4

${samtools} view -bS \
	${outputFolder}/${outputPrefix}Aligned.out.sam \
	> ${outputFolder}/${outputPrefix}Aligned.out.bam

${samtools} sort \
	${outputFolder}/${outputPrefix}Aligned.out.bam \
	${outputFolder}/${outputPrefix}Aligned.out.sorted

${samtools} index \
	${outputFolder}/${outputPrefix}Aligned.out.sorted.bam

rm ${outputFolder}/${outputPrefix}Aligned.out.bam
rm ${outputFolder}/${outputPrefix}Aligned.out.sam

