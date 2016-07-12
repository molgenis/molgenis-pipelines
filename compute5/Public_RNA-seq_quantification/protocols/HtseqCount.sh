#MOLGENIS walltime=24:00:00 nodes=1 cores=1 mem=6gb

#Parameter mapping
#string bam
#string annotationGtf
#string htseqTxtOutput
#string samtoolsVersion
#string htseqVersion
#string stranded
#string htseqDir
#string mode
#string sortType
#string featureType
#string internalId
#string sampleName
#string project

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
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
        -f bam \
        -t ${featureType} \
        --stranded ${stranded} \
        ${bam} \
        ${annotationGtf} >  ${htseqTxtOutput}___tmp___ ;
then
        echo "Gene count succesfull"
        if [[ $(wc -l <${htseqTxtOutput}___tmp___) -ge 2 ]]
        then
            echo "returncode: $?"
            mv ${htseqTxtOutput}___tmp___ ${htseqTxtOutput}
        else
            echo "output not written correctly";
            echo "returncode: 1"
            exit 1;
        fi
else
        echo "Genecount failed"
        echo "returncode: 1"
        exit 1
fi

echo "## "$(date)" ##  $0 Done "
