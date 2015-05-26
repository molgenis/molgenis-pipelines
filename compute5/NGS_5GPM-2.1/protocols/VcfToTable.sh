#MOLGENIS walltime=23:59:00 mem=6gb ppn=1

#Parameter mapping
#string vcf2tabpl
#string variantsFinalVcf
#string variantsFinalVcfTable
#string variantType
#string tmpDataDir
#string project

#Echo parameter values
echo "vcf2tabpl: ${vcf2tabpl}"
echo "variantsFinalVcf: ${variantsFinalVcf}"
echo "variantsFinalVcfTable: ${variantsFinalVcfTable}"

makeTmpDir ${variantsFinalVcfTable}
tmpvariantsFinalVcfTable=${MC_tmpFile}

# adjust the columnheader filtering according to the snp or indel imput vcf.  
if [ ${variantType} == "SNP" ]
then 
filter="AB,AC,AN,BaseCounts,DP,GC,MQ,QD,SB,SNPEFF_AMINO_ACID_CHANGE,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,\
SNPEFF_EXON_ID,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,\
Samples,dbSNP${dbsnpLatestVersionNumber}.AF,dbSNP${dbsnpLatestVersionNumber}.G5,dbSNP${dbsnpLatestVersionNumber}.G5A,\
dbSNP${dbsnpLatestVersionNumber}.KGPROD,dbSNP${dbsnpLatestVersionNumber}.KGPilot1,dbSNP${dbsnpLatestVersionNumber}.KGPilot123,\
dbSNP${dbsnpLatestVersionNumber}.KGVAL,dbSNP${dbsnpLatestVersionNumber}.dbSNPBuildID"

header="Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAllele_balance\tAllele_count\tAllele_number\tBaseCounts_A_C_G_T\tDepth\tGC_content\tMapping_quality\tQuality_by_depth\tStrand_ballance\tsnpEff_amino_acid_change\tsnpEff_codon_change\tsnpEff_effect\tsnpEff_exon_ID\tsnpEff_functional_class\tsnpEff_gene_biotype\tsnpEff_gene_name\tsnpEff_impact\tsnpEff_transcript_ID\tSample\tdbSNP${dbsnpLatestVersionNumber}_allele_frequency\t1KG_>5%_MAF_in_>1_populations\t1KG_>5%_MAF_in_each_and_all_populations\tDiscovered_in_1KG_production_phase\tDiscovered_in_1KG_pilot1\tDiscovered_in_1KG_all_pilots\tDiscovered_in_1KG_and_validated_by_second_method\tFirst_included_in_dbSNP_release\tGenotype"

elif [ ${variantType} == "Indel" ]
then	
filter="AC,AF,AN,BaseCounts,DP,END,HOMLEN,HOMSEQ,MQ,SNPEFF_CODON_CHANGE,\
SNPEFF_EFFECT,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,\
SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,SVLEN,SVTYPE,VariantType,Samples"

header="Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAC\tAF\tAN\tBaseCounts\tDP\tEND\tHOMLEN\tHOMSEQ\tMQ\tSNPEFF_CODON_CHANGE\tSNPEFF_EFFECT\tSNPEFF_FUNCTIONAL_CLASS\tSNPEFF_GENE_BIOTYPE\tSNPEFF_GENE_NAME\tSNPEFF_IMPACT\tSNPEFF_TRANSCRIPT_ID\tSVLEN\tSVTYPE\tVariantType\tSamples" 

else
	echo "${variantType} is not a correct variantType"
	exit 1
fi

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${variantsFinalVcf} \
-output ${variantsFinalVcfTable}.tmp \
-filter ${filter} \
-format GT

echo -e ${header} > ${tmpvariantsFinalVcfTable}

sed '2,$!d' ${tmpvariantsFinalVcfTable}.tmp >> ${tmpvariantsFinalVcfTable}

mv ${tmpvariantsFinalVcfTable} ${variantsFinalVcfTable}
