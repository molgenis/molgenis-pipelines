#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string intervaltreeVersion
#string pyvcfVersion
#string samtoolsVersion
#string phaserDir
#string shapeitPhasedOutputPrefix
#string mapq
#string baseq
#string phaserOutPrefix

getFile ${bam}
if [[ ! -f ${bam} ]] ; then
  exit 1
fi
getFile ${reads2FqGz}
if [[ ! -f ${vcf} ]] ; then
exit 1
fi


#Load modules
${stage} intervaltree/${intervaltreeVersion}
${stage} PyVCF/${pyvcfVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} BEDTools/${bedtoolsVersion}

#check modules
${checkStage}

mkdir -p ${phaserDir}

echo "## "$(date)" Start $0"

if
time python phaser/phaser.py
    --bam ${bam}
    --vcf ${shapeitPhasedOutputPrefix}.haps.gz
    --mapq ${mapq}
    --sample ${sampleName}
    --baseq ${baseq}
    --o ${phaserOutPrefix}
    --temp_dir ${phaserDir}
    --threads 4

then
  echo "returncode: $?";
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
