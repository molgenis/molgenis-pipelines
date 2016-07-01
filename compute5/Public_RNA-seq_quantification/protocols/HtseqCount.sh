#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string bam
#string annotationGtf
#string htseqTxtOutput
#string samtoolsVersion
#string htseqVersion
#string stranded
#string htseqDir

#Echo parameter values
bam="${bam}"
annotationGtf="${annotationGtf}"
htseqTxtOutput="${htseqTxtOutput}"

echo -e "bam=${bam}\nannotationGtf=${annotationGtf}\nhtseqTxtOutput=${htseqTxtOutput}"

module load SAMtools/${samtoolsVersion}
module load HTSeq/${htseqVersion}
module list

echo "Sorting bam file by name"
mkdir -p ${htseqDir}
if samtools \
        sort \
        -n \
        -o ${TMPDIR}/nameSorted.bam \
        ${bam}
then 
        echo "bam file sorted"
else
        echo "Failed to sort bam file"
        rm -f ${TMPDIR}/nameSorted.bam
        exit 1
fi 
ls ${TMPDIR}
echo -e "\nQuantifying expression"

if samtools \
        view -h \
        ${TMPDIR}/nameSorted.bam | \
        htseq-count \
        -m union \
        --stranded ${stranded} \
        - \
        ${annotationGtf} | \
        head -n -5 \
        > ${htseqTxtOutput}___tmp___;
then
        echo "Gene count succesfull"
        mv ${htseqTxtOutput}___tmp___ ${htseqTxtOutput}
else
        echo "Genecount failed"
        rm -f ${TMPDIR}/nameSorted.bam
        exit 1
fi

rm ${TMPDIR}/nameSorted.bam

echo "Finished!"
