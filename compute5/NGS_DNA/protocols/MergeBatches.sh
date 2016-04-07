#MOLGENIS walltime=23:59:00 mem=10gb ppn=2

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tabixVersion
#string tempDir
#string intermediateDir
#string projectVariantsMerged
#string projectVariantsMergedSorted
#list batchID
#string projectPrefix
#string tmpDataDir
#string project
#string logsDir
#string sortVCFpl
#string indexFile
#string indexFileFastaIndex

#Load module GATK,tabix
${stage} ${gatkVersion}
${stage} ${tabixVersion}
${stage} ngs-utils
${checkStage}

makeTmpDir ${projectVariantsMerged}
tmpProjectVariantsMerged=${MC_tmpFile}

makeTmpDir ${projectVariantsMergedSorted}
tmpProjectVariantsMergedSorted=${MC_tmpFile}

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

INPUTS=()

for b in "${batchID[@]}"
do
	if [ -f ${projectPrefix}.batch-${b}.variant.calls.genotyped.vcf ]
	then
		array_contains INPUTS "--variant ${projectPrefix}.batch-${b}.variant.calls.genotyped.vcf" || INPUTS+=("--variant ${projectPrefix}.batch-${b}.variant.calls.genotyped.vcf")
	fi
done

java -Djava.io.tmpdir=${tempDir} -cp ${EBROOTGATK}/${gatkJar} org.broadinstitute.gatk.tools.CatVariants \
-R ${indexFile} \
${INPUTS[@]} \
-out ${tmpProjectVariantsMerged} \
-assumeSorted

#sort and rename VCF file 
${sortVCFpl} \
-fastaIndexFile ${indexFileFastaIndex} \
-inputVCF ${tmpProjectVariantsMerged} \
-outputVCF ${tmpProjectVariantsMergedSorted}

mv ${tmpProjectVariantsMergedSorted} ${projectVariantsMergedSorted}
echo "mv ${tmpProjectVariantsMergedSorted} ${projectVariantsMergedSorted}"
