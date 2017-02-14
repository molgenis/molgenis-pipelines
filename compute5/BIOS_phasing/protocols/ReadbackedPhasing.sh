#MOLGENIS nodes=1 ppn=12 mem=8gb walltime=23:59:59

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string phaserVersion
#string phaserDir
#string shapeitPhasedOutputPrefix
#string shapeitPhasedOutputPostfix
#list bam
#list CHR
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

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))


#Clean environment from "old" python versions
ml purge

#Load module
${stage} phASER/${phaserVersion}
${stage} tabix/${tabixVersion}
${stage} BCFtools/${bcftoolsVersion}
#check modules
${checkStage}

mkdir -p ${phaserDir}
mkdir -p ${phaserDir}/variant_connections/
mkdir -p ${phaserDir}/allelic_counts/
mkdir -p ${phaserDir}/haplotypes/
mkdir -p ${phaserDir}/haplotypic_counts/
mkdir -p ${phaserDir}/allele_config/



#Iterate over all BAM files.
#Do this to prevent running lots of samples in parallel all using the same input VCF.gz file

#Check when last BAM, if so don't replace the GT:etc info fields in VCF
i=0

echo "Looping over bam files..."
for BAM in "${bams[@]}"
do

  let i=i+1

  #Extract sampleName from BAM

  filename=$(basename "$BAM")
  sampleName="${filename%$bamExtension}"

  echo -n "Processing.. "
  echo -n "filename: $filename "
  echo -n "bamExtension: $bamExtension "
  echo -n "sampleName: $sampleName "
  echo "Input vcf: $INPUTVCF"
  phaserOutPrefix=${phaserDir}/${project}_phASER.chr${CHR}

  #Set output prefix per sample for statistics etc.
  TMPOUTPUTVCF="${phaserDir}/${project}_$sampleName.readBackPhased.vcf$i.chr${CHR}"

  if output=$(python $EBROOTPHASER/phaser/phaser.py \
  	  --paired_end 1 \
      --bam $BAM \
      --vcf $INPUTVCF \
      --mapq ${mapq} \
      --sample $sampleName \
      --baseq ${baseq} \
      --o $TMPOUTPUTVCF \
      --temp_dir $TMPDIR \
      --threads 12 \
      --gw_phase_method 1 \
	  --chr ${CHR} \
      --gw_af_vcf ${OneKgPhase3VCF} \
      --gw_phase_vcf 1)
    echo "$output"
    # phaser does't send appropriate exit signal so try like this
    if echo $output | grep -q ERROR;
    then
       echo "returncode: $?";
        echo "fail";
       echo "exit, phASER error"
       exit 1;
    fi
    echo "phaser done"
  # --show_warning 1 --debug 1 \

    # Merge VCF outputs from previous loops with VCF output of current loop
    # if it is the first loop start of with that vcf
    if [ $i -eq 1 ];
    then
        echo "mv $TMPOUTPUTVCF.vcf.gz $phaserOutPrefix.vcf.gz"
        mv $TMPOUTPUTVCF.vcf.gz $phaserOutPrefix.vcf.gz
    else
    	cd ${phaserDir}
        echo "Merging VCF file from step $i with VCF output file of previous step"
        echo "bcftools merge $phaserOutPrefix.vcf.gz $TMPOUTPUTVCF.vcf.gz -O z > $phaserOutPrefix.vcf.gz.tmp"
        bcftools merge $phaserOutPrefix.vcf.gz $TMPOUTPUTVCF.vcf.gz -O z > $phaserOutPrefix.vcf.gz.tmp
        mv $phaserOutPrefix.vcf.gz.tmp $phaserOutPrefix.vcf.gz
	    cd -
    fi
  then
    echo "returncode: $?";
    #Move log files to corresponding directories
    echo " moving log files to corresponding directories"
    mv $TMPOUTPUTVCF.variant_connections.txt ${phaserDir}/variant_connections/
    mv $TMPOUTPUTVCF.allelic_counts.txt ${phaserDir}/allelic_counts/
    mv $TMPOUTPUTVCF.haplotypes.txt ${phaserDir}/haplotypes/
    mv $TMPOUTPUTVCF.haplotypic_counts.txt ${phaserDir}/haplotypic_counts/
    mv $TMPOUTPUTVCF.allele_config.txt ${phaserDir}/allele_config/
  else
   echo "returncode: $?";
   echo "fail";
   exit 1;
  fi

done
echo "Done looping"
#Zip all directories containing logfiles
cd ${phaserDir}
zip -r ${project}.chr${CHR}.variant_connections.zip ./variant_connections/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.allelic_counts.zip ./allelic_counts/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.haplotypes.zip ./haplotypes/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.haplotypic_counts.zip ./haplotypic_counts/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.allele_config.zip ./allele_config/*chr${chromosome}.*


 bname=$(basename $phaserOutPrefix.vcf.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${CHR}.variant_connections.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${CHR}.allelic_counts.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${CHR}.haplotypes.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${CHR}.haplotypic_counts.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${CHR}.allele_config.zip)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";



echo "## "$(date)" ##  $0 Done "

