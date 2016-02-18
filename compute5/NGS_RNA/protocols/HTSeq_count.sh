#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string tempDir
#string annotationGtf
#string sampleHTseqExpressionText
#string htseqVersion
#string samtoolsVersion
#string project

module load ${htseqVersion}
module load ${samtoolsVersion}
module list


makeTmpDir ${sampleHTseqExpressionText}
tmpSampleHTseqExpressionText=${MC_tmpFile}


echo "Sorting bam file by name"

  samtools \
      sort \
      -n \
      ${sampleMergedBam} \
      ${sampleMergedBam}.nameSorted
 
      echo "bam file sorted"

        
echo -e "\nQuantifying expression"

  samtools \
        view -h \
        ${sampleMergedBam}.nameSorted.bam | \
        $EBROOTHTSEQ/scripts/htseq-count \
        -m union \
        -s no \
        - \
        ${annotationGtf} | \
        head -n -5 \
        > ${tmpSampleHTseqExpressionText}

        echo "Gene count succesfull"
        mv ${tmpSampleHTseqExpressionText} ${sampleHTseqExpressionText}
	rm ${sampleMergedBam}.nameSorted.bam

	echo "Finished!"
