#MOLGENIS nodes=1 ppn=1 mem=4gb walltime=5:59:59

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string phaserVersion
#string phaserDir
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix
#string bam
#string sampleName
#string CHR
#string mapq
#string baseq
#string CHR
#string OneKgPhase3VCF
#string tabixVersion
#string bcftoolsVersion
#string bamExtension

echo "## "$(date)" Start $0"

INPUTVCF="${shapeitPhasedOutputPrefix}${CHR}${shapeitPhasedOutputPostfix}.vcf.gz"
if [[ ! -f $INPUTVCF ]] ; then
  >&2 echo "$INPUTVCF does not exist"
  exit 1
fi

# copy vcf to tmpdir so each job reads its own vcf
TMPVCF=${TMPDIR}/$(basename ${shapeitPhasedOutputPrefix}${CHR}${shapeitPhasedOutputPostfix}.vcf.gz)
rsync -vP ${shapeitPhasedOutputPrefix}${CHR}${shapeitPhasedOutputPostfix}.vcf.gz ${TMPDIR}/$(basename ${TMPVCF})
rsync -vP ${shapeitPhasedOutputPrefix}${CHR}${shapeitPhasedOutputPostfix}.vcf.gz.tbi ${TMPDIR}/$(basename ${TMPVCF}).tbi

#Clean environment from "old" python versions
ml purge

#Load module
${stage} phASER/${phaserVersion}
${stage} tabix/${tabixVersion}
${stage} BCFtools/${bcftoolsVersion}
#check modules
${checkStage}

mkdir -p ${phaserDir}/variant_connections/chr$CHR
mkdir -p ${phaserDir}/allelic_counts/chr$CHR
mkdir -p ${phaserDir}/haplotypes/chr$CHR
mkdir -p ${phaserDir}/haplotypic_counts/chr$CHR
mkdir -p ${phaserDir}/allele_config/chr$CHR
mkdir -p ${phaserDir}/vcf_per_sample/chr$CHR

echo  "Processing.. "
echo  "bamExtension: $bamExtension "
echo  "sampleName: $sampleName "
echo "Input vcf: $INPUTVCF"
phaserOutPrefix=${phaserDir}/${project}_phASER.chr${CHR}

#Set output prefix per sample for statistics etc.
TMPOUTPUTVCF="${phaserDir}/${project}_$sampleName.readBackPhased.chr${CHR}"

output=$(python $EBROOTPHASER/phaser/phaser.py \
  --paired_end 1 \
  --bam $bam \
  --vcf $TMPVCF \
  --mapq ${mapq} \
  --sample $sampleName \
  --baseq ${baseq} \
  --o $TMPOUTPUTVCF \
  --temp_dir $TMPDIR \
  --threads 1 \
  --gw_phase_method 1 \
  --chr ${CHR} \
  --gw_af_vcf ${OneKgPhase3VCF} \
  --gw_phase_vcf 1 \
  --show_warning 1 \
  --debug 1)

  echo "$output"

  # phaser does't send appropriate exit signal so try like this
  if echo $output | grep -q ERROR;
  then
     echo "returncode: $?";
     echo "fail";
     >&2 echo $"output"
     >&2 echo "exit, phASER error"
     exit 1;
  fi
echo "phaser done"

echo "returncode: $?";
#Move log files to corresponding directories
echo " moving log files to corresponding directories"
mv $TMPOUTPUTVCF.variant_connections.txt ${phaserDir}/variant_connections/chr$CHR/
mv $TMPOUTPUTVCF.allelic_counts.txt ${phaserDir}/allelic_counts/chr$CHR/
mv $TMPOUTPUTVCF.haplotypes.txt ${phaserDir}/haplotypes/chr$CHR/
mv $TMPOUTPUTVCF.haplotypic_counts.txt ${phaserDir}/haplotypic_counts/chr$CHR/
mv $TMPOUTPUTVCF.allele_config.txt ${phaserDir}/allele_config/chr$CHR/
mv $TMPOUTPUTVCF.vcf.gz ${phaserDir}/vcf_per_sample/chr$CHR/
mv $TMPOUTPUTVCF.vcf.gz.tbi ${phaserDir}/vcf_per_sample/chr$CHR/

