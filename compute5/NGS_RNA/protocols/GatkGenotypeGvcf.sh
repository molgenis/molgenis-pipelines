#MOLGENIS walltime=10-23:59:00 mem=8gb ppn=16

############moet nog aangepast worden ########################
#string stage
#string gatkVersion
#string checkStage
#string tmpTmpDataDir
#string tmpDataDir
#string dbsnpVcf
#string gatkVersion
#string indexFile
#list GatkHaplotypeCallerGvcf,GatkHaplotypeCallerGvcfidx
#string intermediateDir
#string projectPrefix
#string projectBatchGenotypedVariantCalls
#string projectBatchCombinedVariantCalls
#string projectJobsDir
#string project


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

makeTmpDir ${projectBatchGenotypedVariantCalls}
tmpProjectBatchGenotypedVariantCalls=${MC_tmpFile}

#Load modules
${stage} ${gatkVersion}

#Check modules
${checkStage}

echo "## "$(date)" Start $0"

SAMPLESIZE=$(cat ${projectJobsDir}/${project}.csv | wc -l)
numberofbatches=$(($SAMPLESIZE / 200))
ALLGVCFs=()

if [ $SAMPLESIZE -gt 200 ]
then
	for b in $(seq 0 $numberofbatches)
	do
		if [ -f ${projectBatchCombinedVariantCalls}.$b ]
		then
 			ALLGVCFs+=(--variant ${projectBatchCombinedVariantCalls}.$b)
		fi
	done
else
	for sbatch in "${GatkHaplotypeCallerGvcf[@]}"
        do
		if [ -f $sbatch ]
		then
          		array_contains ALLGVCFs "--variant $sbatch" || ALLGVCFs+=("--variant $sbatch")
		fi
        done
fi 
GvcfSize=${#ALLGVCFs[@]}
if [ ${GvcfSize} -ne 0 ]
then

java -Xmx4g -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
 -T GenotypeGVCFs \
 -R ${indexFile} \
 --dbsnp ${dbsnpVcf}\
 -o ${tmpProjectBatchGenotypedVariantCalls} \
${ALLGVCFs[@]} \
 -stand_call_conf 10.0 \
 -stand_emit_conf 20.0 \
 -nt 4

	mv ${tmpProjectBatchGenotypedVariantCalls} ${projectBatchGenotypedVariantCalls}
	echo "moved ${tmpProjectBatchGenotypedVariantCalls} to ${projectBatchGenotypedVariantCalls} "
else
	echo ""
	echo "there is nothing to genotype, skipped"
	echo ""
fi





