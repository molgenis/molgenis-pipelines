#MOLGENIS walltime=01:00:00 mem=1gb ppn=2
#string inputDataTmp
#string ProjectUtrecht
#list externalSampleID
#string utrechtDir

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

if [ ! -d ${inputDataTmp} ]
then
	mkdir -p ${inputDataTmp}
fi


# Copying data to zinc-finger
for externalID in "${externalSampleID[@]}"
do
	array_contains INPUTS "${externalID}_dedup.bam" || INPUTS+=("${externalID}_dedup.bam")
	array_contains INPUTS "${externalID}_dedup.bam.bai" || INPUTS+=("${externalID}_dedup.bam.bai")
done

for i in ${INPUTS[@]}
do
	rsync -av ${utrechtDir}/${i} ${inputDataTmp}
done
echo "rsync done"
