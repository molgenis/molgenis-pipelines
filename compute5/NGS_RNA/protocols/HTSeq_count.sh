#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sortedBam
#string tempDir
#string annotationGtf
#string txtExpression
#string externalSampleID
#string htseqVersion
#string samtoolsVersion


module load ${htseqVersion}
module load ${samtoolsVersion}
module list

echo "Sorting bam file by name"

if samtools \
        sort \
        -n \
        ${sortedBam} \
        ${tempDir}/nameSorted
then 
        echo "bam file sorted"
else
        echo "Failed to sort bam file"
        rm -f ${tempDir}/nameSorted.bam
        exit 1
fi 
        
echo -e "\nQuantifying expression"

if samtools \
        view -h \
        ${tempDir}/nameSorted.bam | \
        htseq-count \
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
        rm -f ${tempDir}/nameSorted.bam
        exit 1
fi

rm ${tempDir}/nameSorted.bam

echo "Finished!"
