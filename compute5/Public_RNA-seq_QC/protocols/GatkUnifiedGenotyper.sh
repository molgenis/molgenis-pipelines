#MOLGENIS walltime=23:59:00 nodes=1 mem=8gb ppn=4

### variables to help adding to database (have to use weave)
#string project
#string sampleName
#string internalId
###
#string stage
#string checkStage
#string onekgGenomeFasta
#string gatkVersion
#list sortedBam
#string unifiedGenotyperDir
#string dbsnpVcf
#string toolDir
#string testIntervalList
#string rawVCF
#string jdkVersion
#string tabixVersion





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

#This check needs to be performed because Compute generates duplicate values in array
sortedBam_uniq=()
for sortedBamFile in "${sortedBam[@]}"
do
        array_contains sortedBam_uniq "$sortedBamFile" || sortedBam_uniq+=("$sortedBamFile")    # If bamFile does not exist in array add it
done




for file in "${sortedBam_uniq[@]}"; do
done

#Load modules
${stage} GATK/${gatkVersion}
${stage} tabix/${tabixVersion}

#check modules
${checkStage}

mkdir -p ${unifiedGenotyperDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#print like '-I=file1.bam -I=file2.bam '
inputs=$(printf ' -I %s ' $(printf '%s\n' ${sortedBam_uniq[@]}))

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}GATK//${gatkVersion}/GenomeAnalysisTK.jar \
  -R ${onekgGenomeFasta} \
  -T UnifiedGenotyper \
  $inputs \
  -L ${testIntervalList} \
  --dbsnp ${dbsnpVcf} \
  -o ${rawVCF} \
  -U ALLOW_N_CIGAR_READS \
  -rf ReassignMappingQuality \
  -out_mode EMIT_ALL_SITES \
  -DMQ 60

# have to gzip for GenometypeHarmonizer usage later
bgzip -c ${rawVCF} > ${rawVCF}.gz
tabix -p vcf ${rawVCF}.gz

then
 echo "returncode: $?";
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
