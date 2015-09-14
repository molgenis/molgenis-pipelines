#MOLGENIS walltime=23:59:00 mem=8gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string capturedBatchBed
#string projectBatchCombinedVariantCalls
#string tmpDataDir
#list externalSampleID
#string batchID

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

makeTmpDir ${projectBatchCombinedVariantCalls}
tmpProjectBatchCombinedVariantCalls=${MC_tmpFile}


#Load GATK module
${stage} ${gatkVersion}
${checkStage}

INPUTS=()
ALLGVCFs=()

for external in "${externalSampleID[@]}"
do
	array_contains INPUTS "$external" || INPUTS+=("$external")    # If bamFile does not exist in array add it
done	

for i in "${INPUTS[@]}"
do
	ALLGVCFs+=("--variant ${intermediateDir}/${i}.batch-${batchID}.variant.calls.g.vcf")
done
count=${#ALLGVCFs[@]}

if [ ${count} -ne 0 ] 
then
	java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
	${EBROOTGATK}/${gatkJar} \
	-T CombineGVCFs \
	-R ${indexFile} \
	-o ${tmpProjectBatchCombinedVariantCalls} \
	${ALLGVCFs[@]} 
else
	echo "ALLGVCFs is empty, probably something is wrong"
	exit 1
fi

mv ${tmpProjectBatchCombinedVariantCalls} ${projectBatchCombinedVariantCalls}
echo "mv ${tmpProjectBatchCombinedVariantCalls} ${projectBatchCombinedVariantCalls}"

