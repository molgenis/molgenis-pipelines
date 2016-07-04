#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string bam
#string annotationGtf
#string htseqTxtOutput
#string samtoolsVersion
#string featureCountVersion
#string stranded
#string htseqDir
#string mode
#string sortType
#string featureType

#Echo parameter values
bam="${bam}"
annotationGtf="${annotationGtf}"
htseqTxtOutput="${htseqTxtOutput}"

echo -e "bam=${bam}\nannotationGtf=${annotationGtf}\nhtseqTxtOutput=${htseqTxtOutput}"

module load SAMtools/${samtoolsVersion}
module load HTSeq/${htseqVersion}
module list

echo "Assuming that the bam file is position sorted, if htseq fails check if your input bam is sorted"
mkdir -p ${htseqDir}

echo -e "\nQuantifying expression"

if htseq-count \
        -m ${mode} \
        -r ${sortType} \
        -f bam \
        -t ${featureType} \
        --stranded ${stranded} \
        -o ${htseqTxtOutput}___tmp___ \
        ${bam} \
        ${annotationGtf} ;
then
        echo "Gene count succesfull"
        if [[ $(wc -l <${htseqTxtOutput}___tmp___) -ge 2 ]]
        then
            mv ${htseqTxtOutput}___tmp___ ${htseqTxtOutput}
        else
            echo "output not written correctly";
            exit 1;
        fi
else
        echo "Genecount failed"
        rm -f ${TMPDIR}/nameSorted.bam
        exit 1
fi

rm ${TMPDIR}/nameSorted.bam

echo "Finished!"
