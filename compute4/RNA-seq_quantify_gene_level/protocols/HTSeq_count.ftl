#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6

sortedBam="${sortedBam}"
htseq_count="${htseq_count}"
annotationGtf="${annotationGtf}"
txtExpression="${txtExpression}"
samtools=${samtools}
python=${python}

<#noparse>

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ntxtExpression=${txtExpression}"

alloutputsexist ${txtExpression}

echo "Sorting bam file by name"

${samtools} \
	sort \
	-n \
	${sortedBam} \
	${TMPDIR}/nameSorted.bam


echo -e "\nQuantifying expression"

if ${samtools} \
	view -h \
	${TMPDIR}/nameSorted.bam | \
	/target/gpfs2/gcc/tools/Python-2.7.3/bin/python \
	${htseq_count} \
	-m union \
	-s no \
	- \
	${annotationGtf} | \
	head -n -5 \
	> ${txtExpression}___tmp___;
then
	echo "Gene count succesfull"
	mv ${txtExpression}___tmp___ ${txtExpression}
else
	echo "Genecount failed"
fi

rm ${sortedBam%bam}byName

echo "Finished!"
</#noparse>
