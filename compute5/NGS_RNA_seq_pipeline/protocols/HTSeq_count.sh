#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sortedBam
#string htseq_count
#string annotationGtf
#string txtExpression
#string externalSampleID

#Echo parameter values
sortedBam="${sortedBam}"
htseq_count="${htseq_count}"
annotationGtf="${annotationGtf}"
txtExpression="${txtExpression}"

echo -e "sortedBam=${sortedBam}\nannotationGtf=${annotationGtf}\ntxtExpression=${txtExpression}"

alloutputsexist ${txtExpression}

module load Python/2.7.5
module load samtools/0.1.18
module list

echo "Sorting bam file by name"

if samtools \
        sort \
        -n \
        ${sortedBam} \
        ${TMPDIR}/nameSorted
then 
        echo "bam file sorted"
else
        echo "Failed to sort bam file"
        rm -f ${TMPDIR}/nameSorted.bam
        exit 1
fi 
        
echo -e "\nQuantifying expression"

if samtools \
        view -h \
        ${TMPDIR}/nameSorted.bam | \
        python \
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
        rm -f ${TMPDIR}/nameSorted.bam
        exit 1
fi

rm ${TMPDIR}/nameSorted.bam

echo "Finished!"
