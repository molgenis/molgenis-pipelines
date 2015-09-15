#MOLGENIS walltime=23:59:00 mem=6gb ppn=6

#Parameter mapping
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
#string projectBatchCombinedGenotypedVariantCalls
#string projectBatchCombinedVariantCalls
#string tmpDataDir
#list externalSampleID

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

makeTmpDir ${projectBatchCombinedGenotypedVariantCalls}
tmpProjectBatchCombinedGenotypedVariantCalls=${MC_tmpFile}


#Load GATK module
${stage} ${gatkVersion}
${checkStage}
if [ -f ${projectBatchCombinedVariantCalls} ]
then
java -Xmx4g -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -jar \
	${EBROOTGATK}/${gatkJar} \
	 -T GenotypeGVCFs \
	 -R ${indexFile} \
	 --dbsnp ${dbSNP137Vcf} \
	 -o ${tmpProjectBatchCombinedGenotypedVariantCalls} \
	 --variant ${projectBatchCombinedVariantCalls} 

	mv ${tmpProjectBatchCombinedGenotypedVariantCalls} ${projectBatchCombinedGenotypedVariantCalls}
	echo "moved ${tmpProjectBatchCombinedGenotypedVariantCalls} to ${projectBatchCombinedGenotypedVariantCalls} "
else
	echo ""
	echo "${projectBatchCombinedVariantCalls} does not exist, skipped"
	echo ""
fi
