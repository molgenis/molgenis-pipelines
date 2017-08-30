#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string genotypeHarmonizerVersion
#string familyID
#string filteredFamilyVCF
#string haplotypeReferencePanelVCFdir
#string haplotypeReferencePanelVCFPrefix
#string convertVCFtoPlinkDir
#string convertVCFtoPlinkPrefix
#list DNAVCFID,RNAVCFID,relation,sex




#################################################################################
#########Function to retrieve indices from array, based on element value#########
#################################################################################
#The function takes two inputs, first is the array to search in, second the
#value to search for
get_index () {
	array=$1[@]
    value=$2
    my_array=("${!array}")
    for i in "${!my_array[@]}"; do
    	if [[ "${my_array[$i]}" = "${value}" ]]; then
        	echo "${i}";
        fi
    done
}
#################################################################################

#################################################################################
#########Function to convert gender names to Plink values #######################
#################################################################################
#The function takes one input, the gender name
get_gender () {
    value=$1
    if [ $value == "male" ]
    then
    	echo "1"
    	
    elif [ $value == "female" ]
    then
    	echo "2"
    	
    elif [ $value == "NA" ]
    then
    	echo "0"
    
    else
    	echo "ERROR: Gender does not match value male, female or NA!"
    	exit
    fi
}



echo "## "$(date)" Start $0"


#Load modules
${stage} GenotypeHarmonizer/${genotypeHarmonizerVersion}
${checkStage}


mkdir -p ${convertVCFtoPlinkDir}



##Extract family relations
DNAIDs=($(printf '%s\n' "${DNAVCFID[@]}"))
RNAIDs=($(printf '%s\n' "${RNAVCFID[@]}"))
relations=($(printf '%s\n' "${relation[@]}"))
genders=($(printf '%s\n' "${sex[@]}"))

#Final array which contains the VCFs to merge
VCFs=()

#Extract child DNA ID and gender from array by index
ChildDNAidx=$(get_index relations "child")
ChildDNAID=${DNAIDs["$ChildDNAidx"]}
ChildGender=${genders["$ChildDNAidx"]}

#Extract father RNA ID and sex from array by index
FatherRNAidx=$(get_index relations "father")
FatherRNAID=${RNAVCFID["$FatherRNAidx"]}
FatherGender=${genders["$FatherRNAidx"]}

#Extract mother RNA ID and sex from array by index
MotherRNAidx=$(get_index relations "mother")
MotherRNAID=${RNAVCFID["$MotherRNAidx"]}
MotherGender=${genders["$MotherRNAidx"]}

#Check if retrieved IDs don't match "NA", if so the value needs to be set to 0 for proper creation of *.fam files below
if [ $MotherRNAID == "NA" ]
then
	MotherRNAID = "0";
	echo "Changed mother RNAID to value: 0";
else
	echo "Succesfully retrieved mother RNAID: $MotherRNAID"
fi

if [ $FatherRNAID == "NA" ]
then
	FatherRNAID = "0";
	echo "Changed father RNAID to value: 0";
else
	echo "Succesfully retrieved father RNAID: $FatherRNAID"
fi

if [ $ChildDNAID == "NA" ]
then
	ChildDNAID = "0";
	echo "Changed child DNAID to value: 0";
else
	echo "Succesfully retrieved child DNAID: $ChildDNAID"
fi

#Check if retrieved genders don't match "NA"
if [ $MotherGender == "NA" ]
then
	MotherGender = "0";
	echo "Changed mother gender to value: 0";
else
	echo "Succesfully retrieved mother gender: $MotherGender"
fi

if [ $FatherGender == "NA" ]
then
	FatherGender = "0";
	echo "Changed father gender to value: 0";
else
	echo "Succesfully retrieved father gender: $FatherGender"
fi

if [ $ChildGender == "NA" ]
then
	ChildGender = "0";
	echo "Changed child gender to value: 0";
else
	echo "Succesfully retrieved child gender: $ChildGender"
fi



##Create BED/BIM files and align to GoNL reference which we use as ref panel for shapeit phasing
java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar $EBROOTGENOTYPEHARMONIZER/GenotypeHarmonizer.jar \
--input ${filteredFamilyVCF} \
--inputType VCF \
--ref ${haplotypeReferencePanelVCFPrefix} \
--refType VCF \
--output ${convertVCFtoPlinkPrefix} \
--outputType PLINK_BED



##Create new *.fam file with correct family ID and relations, by reading file line-by-line to keep order of individuals intact
##According to this format:
##Family ID ('FID')
##Within-family ID ('IID'; cannot be '0')
##Within-family ID of father ('0' if father isn't in dataset)
##Within-family ID of mother ('0' if mother isn't in dataset)
##Sex code ('1' = male, '2' = female, '0' = unknown)
##Phenotype value ('1' = control, '2' = case, '-9'/'0'/non-numeric = missing data if case/control)

mv ${convertVCFtoPlinkPrefix}.fam ${convertVCFtoPlinkPrefix}.original.fam

#If fam file already exists delete it, since we append to file in next step
if [ -f ${convertVCFtoPlinkPrefix}.fam ]
then
	#Remove file
	rm ${convertVCFtoPlinkPrefix}.fam
fi

#Loop over fam file line-by-line
while read line
do
	#Retrieve sample ID from input fam file
	SAMPLE=$(echo "$line" | awk '{print $2}' FS=" ")
	
	if [ $SAMPLE == "$MotherRNAID" ]
	then
		#Detected mother sample
		gender=$(get_gender "$MotherGender")
		echo "${familyID} $MotherRNAID 0 0 $gender -9" >> ${convertVCFtoPlinkPrefix}.fam
	
	elif [ $SAMPLE == "$FatherRNAID" ]
	then
		#Detected father sample
		gender=$(get_gender "$FatherGender")
		echo "${familyID} $FatherRNAID 0 0 $gender -9" >> ${convertVCFtoPlinkPrefix}.fam
	
	elif [ $SAMPLE == "$ChildDNAID" ]
	then
		#Detected father sample
		gender=$(get_gender "$ChildGender")
		echo "${familyID} $ChildDNAID $FatherRNAID $MotherRNAID $gender -9" >> ${convertVCFtoPlinkPrefix}.fam
	
	else
		echo "ERROR: Sample $SAMPLE from ${convertVCFtoPlinkPrefix}.original.fam file can not be found in information from samplesheet!"
		exit;
	fi
done<${convertVCFtoPlinkPrefix}.original.fam




cd ${convertVCFtoPlinkDir}/
md5sum $(basename ${convertVCFtoPlinkPrefix}.bed) > ${convertVCFtoPlinkPrefix}.bed.md5
md5sum $(basename ${convertVCFtoPlinkPrefix}.bim) > ${convertVCFtoPlinkPrefix}.bim.md5
md5sum $(basename ${convertVCFtoPlinkPrefix}.fam) > ${convertVCFtoPlinkPrefix}.fam.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "
