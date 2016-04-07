#MOLGENIS walltime=23:59:00 mem=32gb ppn=4

#Parameter mapping
#string tmpName
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
#string projectJobsDir
#string project
#string logsDir
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

SAMPLESIZE=$(cat ${projectJobsDir}/${project}.csv | wc -l)

## number of batches (+1 is because bash is rounding down) 
numberofbatches=$(($SAMPLESIZE / 200))
gvcfSize=0
for b in $(seq 0 $numberofbatches)
do
	i=0
	ALLGVCFs=()
	for s in "${INPUTS[@]}" 
	do
		VAR=$(($i % ($numberofbatches + 1)))
		if [ $VAR -eq $b ] 
		then
			if [ -f ${intermediateDir}/${s}.batch-${batchID}.variant.calls.g.vcf ] 
			then
				ALLGVCFs+=("--variant ${intermediateDir}/${s}.batch-${batchID}.variant.calls.g.vcf")
			fi
		fi
		i=$((i+1))
 	done
	gvcfSize=${#ALLGVCFs[@]}
	if [ $gvcfSize -ne 0 ]
	then
		java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
        	${EBROOTGATK}/${gatkJar} \
        	-T CombineGVCFs \
        	-R ${indexFile} \
        	-o ${tmpProjectBatchCombinedVariantCalls}.$b \
        	${ALLGVCFs[@]}
	else
		echo "There are no samples for batch-${batchID}.variant.calls.g.vcf"
	fi
done

if [ $gvcfSize -ne 0 ]
then
	for i in $(ls ${tmpProjectBatchCombinedVariantCalls}.*)
	do
		mv $i ${intermediateDir}/$(basename $i)
		echo "mv $i ${intermediateDir}/$(basename $i)"
	done
else
	echo "nothing to move! There are no samples, maybe there is something going wrong, or maybe chrX or chrY are not in the bed file"
fi
