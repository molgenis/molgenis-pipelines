#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string phaserVersion
#string phaserDir
#list shapeitPhasedOutputPrefix
#list bam
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
  putFile ${phaserOutPrefix}.vcf
  putFile ${phaserOutPrefix}.variant_connections.txt
  putFile ${phaserOutPrefix}.allelic_counts.txt
  putFile ${phaserOutPrefix}.haplotypes.txt
  putFile ${phaserOutPrefix}.haplotypic_counts.txt
  putFile ${phaserOutPrefix}.allele_config.txt
  cd ${phaserDir}
 bname=$(basename ${phaserOutPrefix}.vcf)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserOutPrefix}.variant_connections.txt)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserOutPrefix}.allelic_counts.txt)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserOutPrefix}.haplotypes.txt)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserOutPrefix}.haplotypic_counts.txt)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserOutPrefix}.allele_config.txt)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "

