#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string phaserVersion
#string phaserDir
#string shapeitPhasedOutputPrefix
#list bam
#string vcf
#string mapq
#string baseq
#string chromosome
#string OneKgPhase3VCF

echo "## "$(date)" Start $0"


#for file in "${bam[@]}"; do
#	echo "getFile file='$file'"
#	getFile $file
#	if [[ ! -f $file ]] ; then
#  		exit 1
#	fi
#done
if [[ ! -f ${shapeitPhasedOutputPrefix}.vcf.gz ]] ; then
exit 1
fi

#sort unique and print like 'INPUT=file1.bam INPUT=file2.bam '
bams=($(printf '%s\n' "${bam[@]}" | sort -u ))

inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))


#Clean environment from "old" python versions
ml purge

#Load module
${stage} phASER/${phaserVersion}

#check modules
${checkStage}

mkdir -p ${phaserDir}
mkdir -p ${phaserDir}/variant_connections/
mkdir -p ${phaserDir}/allelic_counts/
mkdir -p ${phaserDir}/haplotypes/
mkdir -p ${phaserDir}/haplotypic_counts/
mkdir -p ${phaserDir}/allele_config/


#Set tmp files to use during interation
INPUTVCF="${shapeitPhasedOutputPrefix}.vcf.gz"
TMPINPUTVCF="${phaserDir}/${project}_TMP.chr${chromosome}.vcf.gz"

cp $INPUTVCF $TMPINPUTVCF

#Iterate over all BAM files.
#Do this to prevent running lots of samples in parallel all using the same input VCF.gz file

for BAM in "${bams[@]}"
do

#Extract sampleName from BAM

filename=$(basename "$BAM")
extension="${BAM##*.}"
sampleName="${filename%.*}"

echo ""
echo ""
echo "Processing.."
echo "filename: $filename"
echo "extension: $extension"
echo "sampleName: $sampleName"

phaserOutPrefix=${phaserDir}/${project}_phASER.chr${chromosome}

#Set output prefix per sample for statistics etc.
TMPOUTPUTVCF="${phaserDir}/${project}_$sampleName.readBackPhased.chr${chromosome}"

if python $EBROOTPHASER/phaser/phaser.py \
	--paired_end 1 \
    --bam $BAM \
    --vcf $TMPINPUTVCF \
    --mapq ${mapq} \
    --sample $sampleName \
    --baseq ${baseq} \
    --o $TMPOUTPUTVCF \
    --temp_dir $TMPDIR \
    --threads 4 \
    --gw_phase_method 1 \
	--chr ${chromosome} \
	--gw_af_vcf ${OneKgPhase3VCF} \
	--gw_phase_vcf 1

# --show_warning 1 --debug 1 \
    
then
  echo "returncode: $?";
  #Replace TMPINPUTVCF with newly generated TMPOUTPUTVCF
  rm $TMPINPUTVCF
  mv $TMPOUTPUTVCF.vcf.gz $TMPINPUTVCF
  #Move log files to corresponding directories
  mv $TMPOUTPUTVCF.variant_connections.txt ${phaserDir}/variant_connections/
  mv $TMPOUTPUTVCF.allelic_counts.txt ${phaserDir}/allelic_counts/
  mv $TMPOUTPUTVCF.haplotypes.txt ${phaserDir}/haplotypes/
  mv $TMPOUTPUTVCF.haplotypic_counts.txt ${phaserDir}/haplotypic_counts/
  mv $TMPOUTPUTVCF.allele_config.txt ${phaserDir}/allele_config/
else
 echo "returncode: $?";
 echo "fail";
fi

done

#Zip all directories containing logfiles
cd ${phaserDir}
zip -r ${project}.chr${chromosome}.variant_connections.zip ./variant_connections/
zip -r ${project}.chr${chromosome}.allelic_counts.zip ./allelic_counts/
zip -r ${project}.chr${chromosome}.haplotypes.zip ./haplotypes/
zip -r ${project}.chr${chromosome}.haplotypic_counts.zip ./haplotypic_counts/
zip -r ${project}.chr${chromosome}.allele_config.zip ./allele_config/

#Move final output to result file and create md5sums
 mv $TMPINPUTVCF $phaserOutPrefix.vcf.gz
 putFile $phaserOutPrefix.vcf.gz
 putFile ${phaserDir}/${project}.chr${chromosome}.variant_connections.zip
 putFile ${phaserDir}/${project}.chr${chromosome}.allelic_counts.zip
 putFile ${phaserDir}/${project}.chr${chromosome}.haplotypes.zip
 putFile ${phaserDir}/${project}.chr${chromosome}.haplotypic_counts.zip
 putFile ${phaserDir}/${project}.chr${chromosome}.allele_config.zip

 bname=$(basename $phaserOutPrefix.vcf.gz)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${chromosome}.variant_connections.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${chromosome}.allelic_counts.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${chromosome}.haplotypes.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${chromosome}.haplotypic_counts.zip)
 md5sum ${bname} > ${bname}.md5
 bname=$(basename ${phaserDir}/${project}.chr${chromosome}.allele_config.zip)
 md5sum ${bname} > ${bname}.md5
 cd -
 echo "succes moving files";



echo "## "$(date)" ##  $0 Done "

