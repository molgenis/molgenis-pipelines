#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string phaserVersion
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

#Clean environment from "old" python versions
ml purge

#Load module
${stage} phASER/${phaserVersion}

#check modules
${checkStage}

mkdir -p ${phaserDir}

echo "## "$(date)" Start $0"

if python $EBROOTPHASER/phaser/phaser.py \
    --bam ${bam} \
    --vcf ${shapeitPhasedOutputPrefix}.vcf.gz \
    --mapq ${mapq} \
    --sample ${sampleName} \
    --baseq ${baseq} \
    --o ${phaserOutPrefix} \
    --temp_dir ${phaserDir} \
    --threads 4

then
  echo "returncode: $?";
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
