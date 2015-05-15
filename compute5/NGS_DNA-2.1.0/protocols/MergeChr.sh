#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string tabixVersion
#string tempDir
#string intermediateDir
#string projectVariantsMerged
#string projectSNPsMerged
#string projectIndelsMerged
#string projectVariantsMergedSorted
#list chr
#list projectChrVariantCalls
#string projectPrefix
#string tmpDataDir
#string project
#string sortVCFpl 
#string indexFile
#string indexFileFastaIndex

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "projectVariantCallsMerged: ${projectVariantsMerged}"                                           
echo "projectSNPsMerged: ${projectSNPsMerged}" 
echo "projectIndelsMerged: ${projectIndelsMerged}"
echo "projectVariantsMergedSorted: ${projectVariantsMergedSorted}"

#Load module GATK,tabix
${stage} GATK/${gatkVersion}
${stage} tabix/${tabixVersion}
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
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

INPUTS=()

for c in "${chr[@]}"
do
	
	INPUTS+=("--variant ${projectPrefix}.chr${c}.variant.calls.vcf")
		
done

java -cp ${GATK_HOME}/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants \
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


#prepare the created vcfs for bcftools: bgzip + tabix to set the correct indexes and make correct format
#bgzip -c ${projectIndelsMerged} > ${projectIndelsMerged}.gz
#tabix -p vcf ${projectIndelsMerged}.gz

#move tmpFiles to Intermediatefolder
echo -e "\nMergeChrAndSplitVariants finished succesfull. Moving temp files to final.\n\n"
