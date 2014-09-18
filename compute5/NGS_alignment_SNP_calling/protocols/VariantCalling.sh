#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string baitChrBed
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string projectChrVariantCalls
#string projectChrVariantCallsIdx
#list externalSampleID

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "baitChrBed: ${baitChrBed}"
echo "dbSNP137Vcf: ${dbSNP137Vcf}"
echo "dbSNP137VcfIdx: ${dbSNP137VcfIdx}"

echo "projectChrVariantCalls: ${projectChrVariantCalls}"
echo "projectChrVariantCallsIdx: ${projectChrVariantCallsIdx}"

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${array[@]}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Check if output exists
alloutputsexist \
"${projectChrVariantCalls}"

INPUTS=()

#Get BQSR BAM, idx file and resources
getFile indexFile
getFile dbSNP137Vcf
getFile dbSNP137VcfIdx
for externalID in "${externalSampleID[@]}"
do
  getFile ${intermediateDir}/$externalID.merged.dedup.realigned.bqsr.bam
  getFile ${intermediateDir}/$externalID.merged.dedup.realigned.bqsr.bai
  
  INPUTS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bqsr.bam")
done

#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

makeTmpDir ${projectChrVariantCalls}
tmpProjectChrVariantCalls=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsIdx}
tmpProjectChrVariantCallsIdx=${MC_tmpFile}

#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T HaplotypeCaller \
-R ${indexFile} \
${INPUTS[@]} \
--dbsnp ${dbSNP137Vcf} \
--genotyping_mode DISCOVERY \
-stand_emit_conf 10 \
-stand_call_conf 30 \
-o ${tmpProjectChrVariantCalls} \
-L ${baitChrBed} \
-nct 16

    echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpProjectChrVariantCalls} ${projectChrVariantCalls}
    mv ${tmpProjectChrVariantCallsIdx} ${projectChrVariantCallsIdx}
    putFile "${projectChrVariantCalls}"
    putFile "${projectChrVariantCallsIdx}"

