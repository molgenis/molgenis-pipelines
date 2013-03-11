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

inputs "${snpsfinalvcf}"
alloutputsexist "${snpsfinalvcftable}" "${snpsfinalvcftabletype}" "${snpsfinalvcftableclass}" "${snpsfinalvcftableimpact}"

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${snpsfinalvcf} \
-output ${snpstmpvcftable} \
-filter AB,AC,AN,BaseCounts,DP,GC,MQ,QD,SB,SNPEFF_AMINO_ACID_CHANGE,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,SNPEFF_EXON_ID,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,Samples,dbSNP132.AF,dbSNP132.G5,dbSNP132.G5A,dbSNP132.KGPROD,dbSNP132.KGPilot1,dbSNP132.KGPilot123,dbSNP132.KGVAL,dbSNP132.dbSNPBuildID \
-format GT

echo -e "Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAllele_balance\tAllele_count\tAllele_number\tBaseCounts_A_C_G_T\tDepth\tGC_content\tMapping_quality\tQuality_by_depth\tStrand_ballance\tsnpEff_amino_acid_change\tsnpEff_codon_change\tsnpEff_effect\tsnpEff_exon_ID\tsnpEff_functional_class\tsnpEff_gene_biotype\tsnpEff_gene_name\tsnpEff_impact\tsnpEff_transcript_ID\tSample\tdbSNP132_allele_frequency\t1KG_>5%_MAF_in_>1_populations\t1KG_>5%_MAF_in_each_and_all_populations\tDiscovered_in_1KG_production_phase\tDiscovered_in_1KG_pilot1\tDiscovered_in_1KG_all_pilots\tDiscovered_in_1KG_and_validated_by_second_method\tFirst_included_in_dbSNP_release\tGenotype" > ${snpsfinalvcftable}

sed '2,$!d' ${snpstmpvcftable} >> ${snpsfinalvcftable}


# get SNP statistics
perl ${snpannotationstatspl} \
-vcf_table ${snpsfinalvcftable} \
-typefile ${snpsfinalvcftabletype} \
-classfile ${snpsfinalvcftableclass} \
-impactfile ${snpsfinalvcftableimpact} \
-snptypes DOWNSTREAM,INTERGENIC,INTRAGENIC,INTRON,NON_SYNONYMOUS_CODING,NON_SYNONYMOUS_START,SPLICE_SITE_ACCEPTOR,SPLICE_SITE_DONOR,START_GAINED,START_LOST,STOP_GAINED,STOP_LOST,SYNONYMOUS_CODING,SYNONYMOUS_STOP,UPSTREAM,UTR_3_PRIME,UTR_5_PRIME \
-snpclasses MISSENSE,NONSENSE,NONE,SILENT \
-snpimpacts HIGH,LOW,MODERATE,MODIFIER