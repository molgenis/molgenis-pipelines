#MOLGENIS walltime=23:59:00 mem=10gb

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string variantAnnotatorSampleOutputIndelsVcf
#string variantAnnotatorSampleOutputIndelsFilteredVcf
#string tmpDataDir
#string project
#string logsDir

sleep 5

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${array[@]}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

INPUTS=()

#Load GATK module
${stage} ${gatkVersion}
${checkStage}

makeTmpDir ${variantAnnotatorSampleOutputIndelsFilteredVcf}
tmpVariantAnnotatorSampleOutputIndelsFilteredVcf=${MC_tmpFile}

#Run GATK VariantFiltration to filter called SNPs on 

java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx8g -Xms6g -jar ${EBROOTGATK}/${gatkJar} \
-T VariantFiltration \
-R ${indexFile} \
-o ${tmpVariantAnnotatorSampleOutputIndelsFilteredVcf} \
--variant ${variantAnnotatorSampleOutputIndelsVcf} \
--filterExpression "QD < 2.0" \
--filterName "filterQD" \
--filterExpression "FS > 200.0" \
--filterName "filterFS" \
--filterExpression "ReadPosRankSum < -20.0" \
--filterName "filterReadPosRankSum"

echo -e "\nVariantFiltering finished succesfull. Moving temp files to final.\n\n"
mv ${tmpVariantAnnotatorSampleOutputIndelsFilteredVcf} ${variantAnnotatorSampleOutputIndelsFilteredVcf}
