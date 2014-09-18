#MOLGENIS walltime=01:00:00 mem=4gb

#Parameter mapping
#string chrX_1000G_sampleIDs_female_1000G
#string chrX_1000G_phase1_refpanel_Name 
#string GIANT_tmpWorkDir
#string chrX_1000G_phase1_refpanel_female_only_recode
#string stage
#string GIANT_workDir_originalFiles
#string chrX_1000G_sampleIDs_female_1000G_Name

#Echo parameter values
echo "chrX_1000G_sampleIDs_female_1000G: ${chrX_1000G_sampleIDs_female_1000G}" 
echo "chrX_refpanel_Name: ${chrX_1000G_phase1_refpanel_Name}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}" 
echo "chrX_1000G_phase1_refpanel_female_only_recode: ${chrX_1000G_phase1_refpanel_female_only_recode}" 
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}"

${stage} vcftools

#1000G files ChrX, filtering on female
vcftools \
--keep ${GIANT_workDir_originalFiles}/${chrX_1000G_sampleIDs_female_1000G_Name} \
--gzvcf ${GIANT_workDir_originalFiles}/${chrX_1000G_phase1_refpanel_Name}.vcf.gz \
--recode \
--out ${chrX_1000G_phase1_refpanel_female_only_recode}
