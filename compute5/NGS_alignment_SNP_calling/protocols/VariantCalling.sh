#MOLGENIS walltime=35:59:00 mem=4gb

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
#list BQSRBam
#list BQSRBamIdx
#string tmpProjectVariantCalls
#string tmpProjectVariantCallsIdx
#string projectVariantCalls
#string projectVariantCallsIdx

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
for bam in "${BQSRBam[@]}"
do
  echo "bam: $bam"
done
for bamIdx in "${BQSRBamIdx[@]}"
do
  echo "bamIdx: $bamIdx"
done
echo "tmpProjectVariantCalls: ${tmpProjectVariantCalls}"
echo "tmpProjectVariantCallsIdx: ${tmpProjectVariantCallsIdx}"
echo "projectVariantCalls: ${projectVariantCalls}"
echo "projectVariantCallsIdx: ${projectVariantCallsIdx}"

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Check if output exists
alloutputsexist \
"${projectVariantCalls}"


#Get BQSR BAM, idx file and resources
getFile indexFile
getFile dbSNP137Vcf
getFile dbSNP137VcfIdx
for getBam in "${BQSRBam[@]}"
do
  getFile $getBam
done
for getBamIdx in "${BQSRBamIdx[@]}"
do
  getFile $getBamIdx
done


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

#Create string with input BAM files for GATK HaplotypeCaller
#This check needs to be performed because Compute generates duplicate values in array
INPUTS=()
for bamFile in "${BQSRBam[@]}"
do
	array_contains INPUTS "-I $bamFile" || INPUTS+=("-I $bamFile")    # If bamFile does not exist in array add it
done

#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T HaplotypeCaller \
-R ${indexFile} \
${INPUTS[@]} \
--dbsnp ${dbSNP137Vcf} \
--genotyping_mode DISCOVERY \
-stand_emit_conf 10 \
-stand_call_conf 30 \
-o ${tmpProjectVariantCalls} \
-L ${baitChrBed} \
-nct 16


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode VariantCalling: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpProjectVariantCalls} ${projectVariantCalls}
    mv ${tmpProjectVariantCallsIdx} ${projectVariantCallsIdx}
    putFile "${projectVariantCalls}"
    putFile "${projectVariantCallsIdx}"
    
else
    echo -e "\nFailed to move VariantCalling results to ${intermediateDir}\n\n"
    exit -1
fi