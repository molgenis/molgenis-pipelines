#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string tempDir
#string annotationGtf
#string sampleHTseqExpressionText
#string htseqVersion
#string samtoolsVersion


module load ${htseqVersion}
module load ${samtoolsVersion}
module list


makeTmpDir ${sampleHTseqExpressionText}
tmpSampleHTseqExpressionText=${MC_tmpFile}


echo "Sorting bam file by name"

if samtools \
        sort \
        -n \
        ${sampleMergedBam} \
        ${sampleMergedBam}.nameSorted
then 
        echo "bam file sorted"
else
        echo "Failed to sort bam file"
        rm -f ${sampleMergedBam}.nameSorted.bam
        exit 1
fi 
        
echo -e "\nQuantifying expression"

if samtools \
        view -h \
        ${sampleMergedBam}.nameSorted.bam | \
        htseq-count \
        -m union \
        -s no \
        - \
        ${annotationGtf} | \
        head -n -5 \
        > ${tmpSampleHTseqExpressionText}
then
        echo "Gene count succesfull"
        mv ${tmpSampleHTseqExpressionText} ${sampleHTseqExpressionText}
else
        echo "Genecount failed"
        rm -f ${sampleMergedBam}.nameSorted.bam
        exit 1
fi

rm ${sampleMergedBam}.nameSorted.bam

echo "Finished!"
