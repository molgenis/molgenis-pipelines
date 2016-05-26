#MOLGENIS walltime=23:59:00 mem=8gb ppn=6

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string mergeSamFilesJar
#string sampleMergedBam
#string sampleMergedBai
#string tempDir
#list sortedBam,sortedBai
#string tmpDataDir
#string project
#string intermediateDir
#string picardJar
#string groupname
#string tmpName

sleep 5

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

makeTmpDir ${sampleMergedBam}
tmpSampleMergedBam=${MC_tmpFile}

makeTmpDir ${sampleMergedBai}
tmpSampleMergedBai=${MC_tmpFile}

#Load Picard module
${stage} ${picardVersion}
${checkStage}

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
INPUTBAMS=()
UNIQUEBAIS=()

for bamFile in "${sortedBam[@]}"
do
	array_contains INPUTS "INPUT=$bamFile" || INPUTS+=("INPUT=$bamFile")    # If bamFile does not exist in array add it
	array_contains INPUTBAMS "$bamFile" || INPUTBAMS+=("$bamFile")    # If bamFile does not exist in array add it
done

for baiFile in "${sortedBai[@]}"
do
	array_contains UNIQUEBAIS "$baiFile" || UNIQUEBAIS+=("$baiFile")    # If baiFile does not exist in array add it
done

if [ ${#INPUTS[@]} == 1 ]
then
	ln -sf $(basename ${INPUTBAMS[0]}) ${sampleMergedBam}
	ln -sf $(basename ${UNIQUEBAIS[0]}) ${sampleMergedBai}
	echo "nothing to merge because there is only one sample"

else
	java -XX:ParallelGCThreads=4 -jar -Xmx6g ${EBROOTPICARD}/${picardJar} ${mergeSamFilesJar} \
	${INPUTS[@]} \
	SORT_ORDER=coordinate \
	CREATE_INDEX=true \
	USE_THREADING=true \
	TMP_DIR=${tempDir} \
	MAX_RECORDS_IN_RAM=6000000 \
	VALIDATION_STRINGENCY=LENIENT \
	OUTPUT=${tmpSampleMergedBam}

	echo -e "\nsampleMergedBam finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpSampleMergedBam} ${sampleMergedBam}
	mv ${tmpSampleMergedBai} ${sampleMergedBai}

fi

