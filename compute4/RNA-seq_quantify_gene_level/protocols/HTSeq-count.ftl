#MOLGENIS walltime=20:00:00 nodes=1 cores=1 mem=6

sortedBam="${sortedBam}"
htseq-count="${htseq-count}"
annotationGtf="${annotationGtf}"
txtExpression="${txtExpression}"
samtools=${samtools}

<#noparse>

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ntxtExpression=${txtExpression}"


alloutputsexist ${sortedByName}
echo "Sorting bam file by name"

${samtools} sort \
-n \
${sortedBam} \
${sortedBam%bam}byName


alloutputsexist ${txtExpression}
echo -e "\nQuantifying expression"

/target/gpfs2/gcc/tools/Python-2.7.3/bin/python \
${htseq-count} \
	-m union \
	-s no \
	${sortedBam%bam}byName.bam \
	${annotationGtf} | \
head -n -5 \
> ${txtExpression}

</#noparse>