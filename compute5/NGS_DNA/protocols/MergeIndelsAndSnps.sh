#MOLGENIS walltime=23:59:00 mem=6gb ppn=1

#list externalSampleID
#string tmpName
#string gatkVersion
#string gatkJar
#string indexFile
#string stage
#string checkStage
#string projectPrefix
#string logsDir
#string intermediateDir
#string	project

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

#Load GATK module
${stage} ${gatkVersion}
${checkStage}

INPUTS=()
for SampleID in "${externalSampleID[@]}"
do
        array_contains INPUTS "$SampleID" || INPUTS+=("$SampleID")    # If bamFile does not exist in array add it
done

for externalID in "${INPUTS[@]}"
do
	#create variant array
	VARIANTS+=("--variant ${intermediateDir}/${externalID}.final.vcf")

	java -Xmx2g -jar ${EBROOTGATK}/${gatkJar} \
	-R ${indexFile} \
	-T CombineVariants \
	--variant ${intermediateDir}/${externalID}.snpEff.annotated.filtered.indels.vcf \
	--variant ${intermediateDir}/${externalID}.snpEff.annotated.snps.dbnsfp.vcf \
	--genotypemergeoption UNSORTED \
	-o ${intermediateDir}/${externalID}.final.vcf
done

#merge all samples into one big vcf
java -Xmx2g -jar ${EBROOTGATK}/${gatkJar} \
-R ${indexFile} \
-T CombineVariants \
${VARIANTS[@]} \
-o ${projectPrefix}.final.vcf
