#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=01:00:00

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#list reads1FqGz,reads2FqGz


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


echo "## "$(date)" Start $0"
echo "ID (project-sampleName): ${${project}-${sampleName}"

#check modules
module list

for file in "${reads1FqGz[@]}" "${reads2FqGz[@]}"; do
    echo "getFile file='$file'"
    getFile $file
done


#Create string with input fastq files to merge
#This check needs to be performed because Compute generates duplicate values in array
INPUTFQ1=()
INPUTFQ2=()

echo "merging"
for fq in "${reads1FqGz[@]}"
do
   echo $fq
   array_contains INPUTFQ1 "$fq" || INPUTFQ1+=("$fq")    # If fqFile does not exist in array add it
done
echo "done"
for fq in "${reads2FqGz[@]}"
do
  echo $fq
  array_contains INPUTFQ1 "$fq" || INPUTFQ2+=("$fq")    # If fqFile does not exist in array add it
done

echo "writing to $(dirname reads1FqGz[@])/${sampleName}_R2.fq.gz"

if cat ${INPUTFQ1[*]} > $(dirname reads1FqGz[@])/${sampleName}_R1.fq.gz && cat ${INPUTFQ2[*]} > $(dirname reads1FqGz[@])/${sampleName}_R2.fq.gz
then 
  echo "returncode: $?"; putFile $(dirname reads1FqGz[@])/${sampleName}
  putFile $(dirname reads1FqGz[@])/${sampleName}_R1.fq.gz
  echo "succes moving files";
else
  echo "returncode: $?";
  echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
