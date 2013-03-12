#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=00:40:00
#FOREACH externalSampleID

inputs "${indelsFinalVcf}"
alloutputsexist \
"${indelsFinalVcfTable}"

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${indelsFinalVcf} \
-output ${indelsTmpVcfTable} \
-filter AC,AN,BaseCounts,DP,GC,IndelType,MQ,PindelREF,PindelALT,QD,SNPEFF_AMINO_ACID_CHANGE,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,SNPEFF_EXON_ID,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,Samples \
-format GT

echo -e "Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAllele_count\tAllele_number\tBaseCounts_A_C_G_T\tDepth\tGC_content\tIndelType\tMapping_quality\tPindel_reference_allele\tPindel_alternative_allele\tQuality_by_depth\tsnpEff_amino_acid_change\tsnpEff_codon_change\tsnpEff_effect\tsnpEff_exon_ID\tsnpEff_functional_class\tsnpEff_gene_biotype\tsnpEff_gene_name\tsnpEff_impact\tsnpEff_transcript_ID\tSample\tGenotype" > ${indelsFinalVcfTable}

sed '2,$!d' ${indelsTmpVcfTable} >> ${indelsFinalVcfTable}
