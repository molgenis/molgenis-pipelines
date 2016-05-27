#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string sampleMergedBam
#string tempDir
#string annotationGtf
#string sampleHTseqExpressionText
#string htseqVersion
#string samtoolsVersion
#string project
#string prepKit
#string groupname
#string tmpName

module load ${htseqVersion}
module load ${samtoolsVersion}
module list


makeTmpDir ${sampleHTseqExpressionText}
tmpSampleHTseqExpressionText=${MC_tmpFile}


if [[ "${prepKit}" =~ "Reverse" ]]
then
	echo "Prepkit:${prepKit}, HTSeq-Count STRANDED=reverse is used"
	STRANDED=reverse

elif [[ "${prepKit}" =~ "Lexogen" ]]
then
	echo "Prepkit:${prepKit}, HTSeq-Count STRANDED=yes is used"
	STRANDED=yes

else
	echo "Prepkit:${prepKit} is non stranded: HTSeq-Count STRANDED=no is used"
        STRANDED=no
fi

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
        -s ${STRANDED} \
        - \
        ${annotationGtf} | \
        head -n -5 \
        > ${tmpSampleHTseqExpressionText}

        echo "Gene count succesfull"
        mv ${tmpSampleHTseqExpressionText} ${sampleHTseqExpressionText}
	rm ${sampleMergedBam}.nameSorted.bam

	echo "Finished!"
