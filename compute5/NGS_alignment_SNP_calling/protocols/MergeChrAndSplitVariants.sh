#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string projectVariantsMerged
#string projectSNPsMerged
#string projectIndelsMerged
#string projectVariantsMergedSorted
#list chr
#list projectChrVariantCalls
#string projectPrefix

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "projectVariantCallsMerged: ${projectVariantsMerged}"                                           
echo "projectSNPsMerged: ${projectSNPsMerged}" 
echo "projectIndelsMerged: ${projectIndelsMerged}"
echo "projectVariantsMergedSorted: ${projectVariantsMergedSorted}"

#Load module BWA
${stage} tabix/$0.2.6
${checkStage}

makeTmpDir ${projectVariantsMerged}
tmpProjectVariantsMerged=${MC_tmpFile}

makeTmpDir ${projectSNPsMerged}
tmpProjectSNPsMerged=${MC_tmpFile}

makeTmpDir ${projectIndelsMerged}
tmpProjectIndelsMerged=${MC_tmpFile}

makeTmpDir ${projectVariantsMergedSorted}
tmpProjectVariantsMergedSorted=${MC_tmpFile}

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
alloutputsexist "${projectSNPsMerged}"
alloutputsexist "${projectIndelsMerged}"

#for getVariants in "$chr"
#do
#  getFile $getVariants
#done

INPUTS=()
for c in "${chr[@]}"
do
  getFile ${projectPrefix}.chr${c}.variant.calls.vcf
  getFile ${projectPrefix}.chr${c}.variant.calls.vcf.idx
  INPUTS+=(${projectPrefix}.chr${c}.variant.calls.vcf)
done

#load vcftools
module load vcftools/0.1.12a
module list

#Concatenate projectChrVariantCalls to one file

echo "INFO: Concatenate projectChrVariantCalls to one file"
vcf-concat "${INPUTS[@]}" > ${tmpProjectVariantsMerged}

#sort VCF file
echo "INFO: Sort variants"
#cat ${tmpProjectVariantsMerged} | vcf-sort --chromosomal-order > ${tmpProjectVariantsMergedSorted}
cat ${tmpProjectVariantsMerged} | vcf-sort --chromosomal-order > ${projectVariantsMergedSorted}

#split vcriant in SNPS and indels
echo "INFO: split vatiant into SNPs and indels"
vcftools --vcf ${projectVariantsMergedSorted} --keep-only-indels --out ${tmpProjectIndelsMerged} --recode --recode-INFO-all
vcftools --vcf ${projectVariantsMergedSorted} --remove-indels --out ${tmpProjectSNPsMerged} --recode --recode-INFO-all

#rename recode.vcf file to SNP and Indel filenames
mv ${tmpProjectIndelsMerged}.recode.vcf ${tmpProjectIndelsMerged}
mv ${tmpProjectSNPsMerged}.recode.vcf ${tmpProjectSNPsMerged}

#move tmpFiles to Intermediatefolder
echo -e "\nMergeChrAndSplitVariants finished succesfull. Moving temp files to final.\n\n"
mv ${tmpProjectSNPsMerged} ${projectSNPsMerged}
mv ${tmpProjectIndelsMerged} ${projectIndelsMerged}
putFile "${projectSNPsMerged}"
putFile "${projectIndelsMerged}"

#prepare the created vcf's for bcftools: bgzip + tabix to set the correct indexes and make correct format
bgzip -c ${projectIndelsMerged} > ${projectIndelsMerged}.gz
tabix -p vcf ${projectIndelsMerged}.gz; \
