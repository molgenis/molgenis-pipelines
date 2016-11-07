#MOLGENIS nodes=1 ppn=12 mem=8gb walltime=3-10:00:00

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
#string CHR
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
TMPINPUTVCF="${phaserDir}/${project}_TMP.chr${CHR}.vcf.gz"

cp $INPUTVCF $TMPINPUTVCF

#Iterate over all BAM files.
#Do this to prevent running lots of samples in parallel all using the same input VCF.gz file

#Check when last BAM, if so don't replace the GT:etc info fields in VCF
i=0
last_bam=${#bams[@]}

for BAM in "${bams[@]}"
do

let i=i+1

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

phaserOutPrefix=${phaserDir}/${project}_phASER.chr${CHR}

#Set output prefix per sample for statistics etc.
TMPOUTPUTVCF="${phaserDir}/${project}_$sampleName.readBackPhased.chr${CHR}"

if python $EBROOTPHASER/phaser/phaser.py \
	--paired_end 1 \
    --bam $BAM \
    --vcf $TMPINPUTVCF \
    --mapq ${mapq} \
    --sample $sampleName \
    --baseq ${baseq} \
    --o $TMPOUTPUTVCF \
    --temp_dir $TMPDIR \
    --threads 12 \
    --gw_phase_method 1 \
	--chr ${CHR} \
	--gw_af_vcf ${OneKgPhase3VCF} \
	--gw_phase_vcf 1

# --show_warning 1 --debug 1 \

	#Unzip output VCF, inline replace messed up header lines, afterwards replace sample output and gzip file again
	cd ${phaserDir}
	gunzip ${project}_$sampleName.readBackPhased.chr${CHR}.vcf.gz
	if [ $i -ne $last_bam ]; 
	then
		#Replace header lines
		perl -pi -e '!$x && s/##FORMAT=<ID=PG,Number=1,Type=String,Description="phASER Local Genotype">\n//  && ($x=1)' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
		perl -pi -e '!$x && s/##FORMAT=<ID=PB,Number=1,Type=String,Description="phASER Local Block">\n//  && ($x=1)' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
		perl -pi -e '!$x && s/##FORMAT=<ID=PI,Number=1,Type=String,Description="phASER Local Block Index \(unique for each block\)">\n//  && ($x=1)' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
		perl -pi -e '!$x && s/##FORMAT=<ID=PW,Number=1,Type=String,Description="phASER Genome Wide Genotype">\n//  && ($x=1)' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
		perl -pi -e '!$x && s/##FORMAT=<ID=PC,Number=1,Type=String,Description="phASER Genome Wide Confidence">\n//  && ($x=1)' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
		
		#Replace sample output line
		perl -pi -e 's/:PG:PB:PI:PW:PC//gs' "${project}_$sampleName.readBackPhased.chr${CHR}.vcf";
	fi
	perl -pi -e 's/:.:.:.:.:.//gs' ${project}_$sampleName.readBackPhased.chr${CHR}.vcf
	gzip ${project}_$sampleName.readBackPhased.chr${CHR}.vcf
	cd -
    
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
zip -r ${project}.chr${CHR}.variant_connections.zip ./variant_connections/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.allelic_counts.zip ./allelic_counts/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.haplotypes.zip ./haplotypes/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.haplotypic_counts.zip ./haplotypic_counts/*chr${chromosome}.*
zip -r ${project}.chr${CHR}.allele_config.zip ./allele_config/*chr${chromosome}.*

#Move final output to result file and create md5sums
 mv $TMPINPUTVCF $phaserOutPrefix.vcf.gz
 putFile $phaserOutPrefix.vcf.gz
 putFile ${phaserDir}/${project}.chr${CHR}.variant_connections.zip
 putFile ${phaserDir}/${project}.chr${CHR}.allelic_counts.zip
 putFile ${phaserDir}/${project}.chr${CHR}.haplotypes.zip
 putFile ${phaserDir}/${project}.chr${CHR}.haplotypic_counts.zip
 putFile ${phaserDir}/${project}.chr${CHR}.allele_config.zip

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

