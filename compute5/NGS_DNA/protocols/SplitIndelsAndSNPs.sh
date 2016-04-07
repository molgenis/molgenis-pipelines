#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string intermediateDir
#string project
#string logsDir
#string gatkVersion
#string gatkJar
#string indexFile
#string capturedIntervals
#string variantAnnotatorOutputVcf
#string variantAnnotatorSampleOutputIndelsVcf
#string variantAnnotatorSampleOutputSnpsVcf
#string externalSampleID

#Load GATK,bcftools,tabix module
${stage} ${gatkVersion}
${checkStage}

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

#select only Indels
java -XX:ParallelGCThreads=2 -Xmx4g -jar ${EBROOTGATK}/${gatkJar} \
-R ${indexFile} \
-T SelectVariants \
--variant ${variantAnnotatorOutputVcf} \
-o ${variantAnnotatorSampleOutputIndelsVcf} \
-L ${capturedIntervals} \
--selectTypeToInclude INDEL \
-sn ${externalSampleID}

#Select SNPs and MNPs
java -XX:ParallelGCThreads=2 -Xmx4g -jar ${EBROOTGATK}/${gatkJar} \
-R ${indexFile} \
-T SelectVariants \
--variant ${variantAnnotatorOutputVcf} \
-o ${variantAnnotatorSampleOutputSnpsVcf} \
-L ${capturedIntervals} \
--selectTypeToExclude INDEL \
-sn ${externalSampleID}
