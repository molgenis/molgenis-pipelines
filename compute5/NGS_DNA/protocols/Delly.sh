#MOLGENIS walltime=23:59:00 mem=4gb
#string project
#string indexFile
#string intermediateDir
#string dellyVersion
#string dellyType
#list dedupBam
#string dellyVcf

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

makeTmpDir ${dellyVcf}
tmpDellyVcf=${MC_tmpFile}


for bamFile in "${dedupBam[@]}"
do
        array_contains UNIQUEBAMS "$bamFile" || UNIQUEBAMS+=("$bamFile")    # If bamFile does not exist in array add it
done

echo "Size of the UNIQUEBAMS: ${#UNIQUEBAMS[@]}"

${EBROOTDELLY}/delly \
-n \
-t ${dellyType} \
-x human.hg19.excl.tsv \
-o ${tmpDellyVcf} \
-g ${indexFile} \
${UNIQUEBAMS[@]}

mv ${tmpDellyVcf} ${dellyVcf}
echo "moved ${tmpDellyVcf} to ${dellyVcf}"
