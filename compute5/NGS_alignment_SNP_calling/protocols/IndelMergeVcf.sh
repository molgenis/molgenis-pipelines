#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string intermediateDir
#string project
#string projectIndelsMerged
#list externalSampleID

#Load Bcftools module
${stage} bcftools/0.2.0

#Load Tabix module
${stage} tabix/0.2.6
${checkStage}

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#prepare the created vcf's for bcftools: bgzip + tabix to set the correct indexes and make correct format

for externalSample in "${externalSampleID[@]}"
do
  echo "externalSampleID: ${externalSample}"
done

sleep 10

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}
vcfTmpDir="${tmpIntermediateDir}/vcfTmpDir"

if [ ! -d ${vcfTmpDir ]
then 
	mkdir ${vcfTmpDir}
fi

INPUTS=()
for sample in "${externalSampleID[@]}"
do
        array_contains INPUTS "INPUT=$sample" || INPUTS+=("INPUT=$sample")    # If sample does not exist in array add it
done

for s in "${INPUTS[@]}"
do
	bgzip -c ${intermediateDir}/${s}.output.pindel.merged.vcf > ${tmpIntermediateDir}/${s}.output.pindel.merged.vcf.gz
        tabix -p vcf ${tmpIntermediateDir}/${s}.output.pindel.merged.vcf.gz
        echo ${tmpIntermediateDir}/${s}; 
	cp ${tmpIntermediateDir}/${s}.output.pindel.merged.vcf.gz ${vcfTmpDir}
done


cp ${projectIndelsMerged}.gz ${vcfTmpDir}

cd ${vcfTmpDir}
#merging all the vcf.gz that were created per sample into one big vcf
echo "running bcftools:"
bcftools merge *.vcf.gz --output-type v > ${tmpIntermediateDir}${project}.indels.calls.mergedAllVcf.vcf

echo "written ${project}.indels.calls.mergedAllVcf.vcf TO ${tmpIntermediateDir}"

mv ${tmpIntermediateDir}${project}.indels.calls.mergedAllVcf.vcf ${intermediateDir}${project}.indels.calls.mergedAllVcf.vcf

if [ -d ${vcfTmpDir} ]
then
	rm -rf ${vcfTmpDir}
fi
