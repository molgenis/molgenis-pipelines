#MOLGENIS walltime=01:00:00 mem=4gb

#Parameter mapping
#string chrX_1000G_phase1_refpanel_female_only_recode
#string stage

#Echo parameter values
echo "chrX_1000G_phase1_refpanel_female_only_recode: ${chrX_1000G_phase1_refpanel_female_only_recode}.recode" 

${stage} tabix

bgzip -c ${chrX_1000G_phase1_refpanel_female_only_recode}.recode.vcf \
> ${chrX_1000G_phase1_refpanel_female_only_recode}.recode.vcf.gz
tabix -p vcf ${chrX_1000G_phase1_refpanel_female_only_recode}.recode.vcf.gz

