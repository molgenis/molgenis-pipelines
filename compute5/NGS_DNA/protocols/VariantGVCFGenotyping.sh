#MOLGENIS walltime=23:59:00 mem=17gb ppn=2

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
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string projectBatchGenotypedVariantCalls
#string project
#string projectBatchCombinedVariantCalls
#list sampleBatchVariantCalls
#string tmpDataDir
#string projectJobsDir
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

makeTmpDir ${projectBatchGenotypedVariantCalls}
tmpProjectBatchGenotypedVariantCalls=${MC_tmpFile}

#Load GATK module
${stage} ${gatkVersion}
${checkStage}

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
	for sbatch in "${sampleBatchVariantCalls[@]}"
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
java -Xmx16g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
	${EBROOTGATK}/${gatkJar} \
	 -T GenotypeGVCFs \
	 -R ${indexFile} \
	 -L ${capturedBatchBed} \
	 --dbsnp ${dbSNP137Vcf} \
	 -o ${tmpProjectBatchGenotypedVariantCalls} \
	${ALLGVCFs[@]} 

	mv ${tmpProjectBatchGenotypedVariantCalls} ${projectBatchGenotypedVariantCalls}
	echo "moved ${tmpProjectBatchGenotypedVariantCalls} to ${projectBatchGenotypedVariantCalls} "
else
	echo ""
	echo "there is nothing to genotype, skipped"
	echo ""
fi
