#MOLGENIS walltime=23:59:00 mem=4gb ppn=10

#Parameter mapping
#string stage
#string checkStage
#string samtoolsVersion
#string sampleMergedBam
#string sampleMergedBai
#string sampleMergedBamIdx
#string tempDir
#list inputMergeBam
#string tmpDataDir
#string project
#string intermediateDir
#string sambambaVersion
#string sambambaTool

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

makeTmpDir ${sampleMergedBamIdx}
tmpSampleMergedBamIdx=${MC_tmpFile}

${stage} ${sambambaVersion}
${checkStage}

#Create string with input BAM files for Picard
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
INPUTBAMS=()

for bamFile in "${inputMergeBam[@]}"
do
	array_contains INPUTS "$bamFile" || INPUTS+=("$bamFile")    # If bamFile does not exist in array add it
	array_contains INPUTBAMS "$bamFile" || INPUTBAMS+=("$bamFile")    # If bamFile does not exist in array add it
done

if [ ${#INPUTS[@]} == 1 ]
then
	ln -sf ${INPUTBAMS[0]} ${sampleMergedBam}
	echo "nothing to merge because there is only one sample"

else
	${EBROOTSAMBAMBA}/${sambambaTool} merge \
	${tmpSampleMergedBam} \
	${INPUTS[@]}

	mv ${tmpSampleMergedBam} ${sampleMergedBam}
	mv ${tmpSampleMergedBamIdx} ${sampleMergedBamIdx}
	echo "mv ${tmpSampleMergedBam} ${sampleMergedBam}"
	echo "mv ${tmpSampleMergedBamIdx} ${sampleMergedBamIdx}"

fi

ln -sf ${sampleMergedBamIdx} ${sampleMergedBai}
echo "ln -sf ${sampleMergedBamIdx} ${sampleMergedBai}"
