#MOLGENIS walltime=0:10:00 mem=1gb
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string projectDir
#string couplingFile
#list sampleName,bam
echo "## "$(date)" Start $0"


#Load gatk module
${checkStage}

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

array=()
echo "merging sampleName and bam array..."
x=0
for file in "${sampleName[@]}"; do
   array+=("${sampleName[x]}_123_SEP_321_$(basename ${bam[x]%.bam})")
   x=$(($x + 1))
done

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
array_uniq=()
echo "making merged array uniq..."
for sampleNameBamfile in "${array[@]}"
do
        array_contains array_uniq "$sampleNameBamfile" || array_uniq+=("$sampleNameBamfile")    # If bamFile does not exist in array add it
done

if [ -f ${couplingFile} ];
  rm ${couplingFile}
fi
echo "making coupling file..."
for sampleNameBamfile in "${array_uniq[@]}"
do
    echo $sampleNameBamfile | awk -F"_123_SEP_321_" '{print $1 "\t" $2}' >> ${couplingFile}
done


echo "## "$(date)" ##  $0 Done "

