#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string gatkVersion
#string selectVariantsBiallelicSNPsVcf
#string ASEReadCountsDir

#list sampleName
#list bam

containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}



echo "## "$(date)" Start $0"


${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p BLA



#for BAM in "${bam[@]}"
#do
#	echo "BAM: $BAM"
#done


#Read VCF header
#push samples in list
#check if for each sample a count file exists
#iterate over VCF file, for each line
  #check if event exists for sample, add to file, otherwise add 0,0

#Extract headerline from VCF
#HEADERLINE=`zcat ${selectVariantsBiallelicSNPsVcf} | head -2000 | grep "^#CHR"`
HEADERLINE=`zcat /groups/umcg-bios/tmp04/projects/ASE_GoNL/rasqual/test/testInputCreateCountsTable/LL.chrALL.20160509-updated-chr1_2500_exonic_snps.vcf.gz | head -2000 | grep "^#CHR"`

#Push headerline in array
SAMPLESVCF=(`echo $HEADERLINE | sed 's/,/\t/g'`)

#Check if every sample from samplesheet.csv file is present in the input VCF file, if not exit;
for SAMPLE in "${sampleName[@]}"
do
	containsElement "$SAMPLE" "${SAMPLESVCF[@]}"
	if [ $? == "0" ]
	then
		echo "Sample: $SAMPLE exists in VCF file"
	else
		echo "Sample: $SAMPLE does not exists in VCF file, exiting now!"
		exit 2;
	fi
done


#Loop through samples in VCF file and check if count file exists for all
for ((i=9; i<${#SAMPLESVCF[*]}; i++))
do
  	SAMVCF=${SAMPLESVCF[i]}
    echo $SAMVCF
    COUNTSFILE="${ASEReadCountsDir}/$SAMVCF.ASEReadCounts.chr${CHR}.rtable"
	
	[ ! -f "$COUNTSFILE" ] && { echo "Error: $COUNTSFILE file not found."; exit 2; }
 
	if [ -s "$COUNTSFILE" ] 
	then
		echo "$COUNTSFILE has some data."
        # do something as file has data
        
        #Grep counts from file, based on chromosomal positions
        TMPFILE="/groups/umcg-bios/tmp04/projects/ASE_GoNL/rasqual/test/testInputCreateCountsTable/LL.chrALL.20160509-updated-chr1_2500_exonic_snps.vcf.gz.tmp"
        zcat /groups/umcg-bios/tmp04/projects/ASE_GoNL/rasqual/test/testInputCreateCountsTable/LL.chrALL.20160509-updated-chr1_2500_exonic_snps.vcf.gz | grep -v '^#' | awk '{print $2}' FS="\t" > $TMPFILE
        
        while read line
        do
        	POS=$line
        	echo "Pos: $POS"
        	GREPCMD="$CHR\t$POS\t"
        	echo "$GREPCMD"
        	RES=$(grep -P "$GREPCMD" $COUNTSFILE)
        	echo "res: $RES"
        	
        done<"$TMPFILE"
        #rm "$TMPFILE"
        
	else
		echo "$COUNTSFILE is completely empty."
        # do something as file is empty
        exit 2;
	fi

done











#if

#then
# echo "returncode: $?"; 
# putFile BLA
# putFile BLA.idx
# echo "succes moving files";
#else
# echo "returncode: $?";
# echo "fail";
#fi

echo "## "$(date)" ##  $0 Done "