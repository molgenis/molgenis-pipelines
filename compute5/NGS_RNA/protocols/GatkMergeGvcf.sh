#MOLGENIS walltime=43:59:00 mem=32gb ppn=4
#string stage
#string gatkVersion
#string checkStage
#string tmpTmpDataDir
#string tmpDataDir
#string dbsnpVcf
#string gatkVersion
#string indexFile
#list GatkHaplotypeCallerGvcf,GatkHaplotypeCallerGvcfidx
#list externalSampleID
#string indexChrIntervalList,chr
#string intermediateDir
#string projectPrefix
#string projectBatchGenotypedVariantCalls
#string projectBatchCombinedVariantCalls
#string projectJobsDir
#string project
#string groupname
#string tmpName

makeTmpDir ${projectBatchCombinedVariantCalls}
tmpProjectBatchCombinedVariantCalls=${MC_tmpFile}

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

#Load modules
${stage} ${gatkVersion}

#Check modules
${checkStage}

echo "## "$(date)" Start $0"

INPUTS=()
ALLGVCFs=()

for external in "${externalSampleID[@]}"
do
	array_contains INPUTS "$external" || INPUTS+=("$external")    # If vcfFile does not exist in array add it
done	

SAMPLESIZE=${#INPUTS[@]}

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
			if [ -f ${intermediateDir}/${s}.GatkHaplotypeCallerGvcf.g.vcf ] 
			then
				ALLGVCFs+=("--variant ${intermediateDir}/${s}.GatkHaplotypeCallerGvcf.g.vcf")
			fi
		fi
		i=$((i+1))
 	done
	gvcfSize=${#ALLGVCFs[@]}
	echo "batchsize is ${gvcfSize}"
	
	if [ $gvcfSize -ne 0 ]
	then
		java -Xmx30g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tmpTmpDataDir} -jar \
        	${EBROOTGATK}/GenomeAnalysisTK.jar \
        	-T CombineGVCFs \
        	-R ${indexFile} \
		-L ${indexChrIntervalList} \
        	-o ${tmpProjectBatchCombinedVariantCalls}.${b} \
        	${ALLGVCFs[@]}
	else
		echo "There are no samples "
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
