#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string phaserVersion
#string phaserDir
#string shapeitPhasedOutputPrefix
#list sampleName
#list bam
#string mapq
#string baseq
#string phaserOutPrefix
#string project
#string chromosome
#string OneKgPhase3VCF

echo "## "$(date)" Start $0"


for file in "${bam[@]}"; do
	echo "getFile file='$file'"
	getFile $file
	if [[ ! -f $file ]] ; then
  		exit 1
	fi
done
if [[ ! -f ${shapeitPhasedOutputPrefix}.vcf.gz ]] ; then
exit 1
fi

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bams[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))



#Clean environment from "old" python versions
ml purge

#Load module
${stage} phASER/${phaserVersion}

#check modules
${checkStage}

mkdir -p ${phaserDir}

if python $EBROOTPHASER/phaser/phaser.py \
	--paired_end 1 \
    --bam ${bam} \
    --vcf ${shapeitPhasedOutputPrefix}.vcf.gz \
    --mapq ${mapq} \
    --sample ${sampleName} \
    --baseq ${baseq} \
    --o ${phaserOutPrefix} \
    --temp_dir ${phaserDir} \
    --threads 4
    --gw_phase_method 1 \
	--chr ${chromosome} \
	--gw_af_vcf ${OneKgPhase3VCF} \
	--gw_phase_vcf 1

# --show_warning 1 --debug 1 \
    
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

