#MOLGENIS walltime=23:59:00 mem=4gb
#string project
#string indexFile
#string intermediateDir
#string dellyVersion
#string dellyType
#list realignedBam

module load delly/${dellyVersion}
module list

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

UNIQUEBAMS=()


for bamFile in "${realignedBam[@]}"
do
        array_contains UNIQUEBAMS "$bamFile" || UNIQUEBAMS+=("$bamFile")    # If bamFile does not exist in array add it
done

echo "Size of the UNIQUEBAMS: ${#UNIQUEBAMS[@]}"
echo "Delly is saving output in: ${intermediateDir}/${project}.delly.vcf"

${EBROOTDELLY}/delly \
-t ${dellyType} \
-x human.hg19.excl.tsv \
-o ${intermediateDir}/${project}.delly.vcf \
-g ${indexFile} \
${UNIQUEBAMS[@]}
