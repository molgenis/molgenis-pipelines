#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string selectVariantsBiallelicSNPsVcf
#string ASEReadCountsDir
#string countsTableDir
#string countsTable
#list sampleName
#list bam

#Function to check if a value is present in array/list
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}



echo "## "$(date)" Start $0"

getFile ${selectVariantsBiallelicSNPsVcf}


${checkStage}

mkdir -p ${countsTableDir}


#Check if output file already exists, if so exit
if [ -f "${countsTable}" ];
then
   echo -e -n "${countsTable} exists\n"
   exit 2;
else
   echo -e -n "${countsTable} does not exist, continuing analysis\n"
fi

#Extract headerline from VCF
HEADERLINE=`zcat ${selectVariantsBiallelicSNPsVcf} | head -2000 | grep "^#CHR"`

#Push headerline in array
SAMPLESVCF=(`echo $HEADERLINE | sed 's/,/\t/g'`)


#Check if every sample from samplesheet.csv file is present in the input VCF file, if not exit;
echo "#####################################"
echo "Checking if all samples specified in input samplesheet.csv exist in VCF header"
echo "#####################################"

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
echo "#####################################"
echo "All samples exist, continuing processing"
echo "#####################################"
echo -e -n "\n\n\n"



#Loop through samples in VCF file and check if ASEReads converted count file exists for all
echo "#####################################"
echo "Checking if a converted ASEReadsCounter file exists for all samples specified in VCF file"
echo "#####################################"

for ((i=9; i<${#SAMPLESVCF[*]}; i++))
do
  	SAMVCF=${SAMPLESVCF[i]}
    echo "Sample: $SAMVCF"
    COUNTSFILE="${countsTableDir}/$SAMVCF.ASEReadCounts.countsTable.chr${CHR}.txt"
	
	[ ! -f "$COUNTSFILE" ] && { echo "Error: $COUNTSFILE file not found."; exit 2; }
 
	if [ -s "$COUNTSFILE" ] 
	then
		echo "File: $COUNTSFILE has some data."
        # do something as file has data
        
	else
		echo "File: $COUNTSFILE is completely empty."
        # do something as file is empty
        exit 2;
	fi
done
echo "#####################################"
echo "All converted GATK ASEReadsCounter files exist, continuing processing"
echo "#####################################"
echo -e -n "\n\n\n"


echo "#####################################"
echo "Pasting all sample count tables into one big table"
echo "#####################################"

toPasteArray=()
#Loop over count files
for ((j=9; j<${#SAMPLESVCF[*]}; j++))
do

	SAMVCF=${SAMPLESVCF[j]}
	#echo $SAMVCF
	COUNTSFILE="${countsTableDir}/$SAMVCF.ASEReadCounts.countsTable.chr${CHR}.txt"
	toPasteArray+=("$COUNTSFILE")
	
done

# Paste all countTables into one
paste -d "\t" ${toPasteArray[@]} > ${countsTable}


echo "#####################################"
echo "Done pasting, Counts table created"
echo "#####################################"
echo -e -n "\n\n\n"


#Putfile the results
if [ -f "${countsTable}" ];
then
 echo "returncode: $?"; 
 putFile ${countsTable}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "