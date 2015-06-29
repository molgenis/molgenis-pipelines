#MOLGENIS walltime=23:59:00 mem=8gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string baitBatchBed
#string projectBatchCombinedVariantCalls
#string tmpDataDir
#list externalSampleID
#string batchID

sleep 10

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

makeTmpDir ${projectBatchCombinedVariantCalls}
tmpProjectBatchCombinedVariantCalls=${MC_tmpFile}


#Load GATK module
${stage} GATK/${gatkVersion}
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

if [ -f ${intermediateDir}/${i}.batch-${batchID}.variant.calls.g.vcf ] 
then
	java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
	${GATK_HOME}/${gatkJar} \
	-T CombineGVCFs \
	-R ${indexFile} \
	-o ${tmpProjectBatchCombinedVariantCalls} \
	${ALLGVCFs[@]} 

	mv ${tmpProjectBatchCombinedVariantCalls} ${projectBatchCombinedVariantCalls}

else
	echo ""
	echo "${intermediateDir}/${i}.batch-${batchID}.variant.calls.g.vcf does not exist, skipped!"
	echo ""
fi

