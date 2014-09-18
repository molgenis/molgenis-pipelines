
#MOLGENIS walltime=00:40:00
#FOREACH externalSampleID

module load GATK/1.0.5069
module list

inputs "${snpsfinalvcf}"
alloutputsexist "${snpsfinalvcftable}" "${snpsfinalvcftabletype}" "${snpsfinalvcftableclass}" "${snpsfinalvcftableimpact}"

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${snpsfinalvcf} \
-output ${snpstmpvcftable} \
-filter AB,AC,AN,BaseCounts,DP,GC,MQ,QD,SB,SNPEFF_AMINO_ACID_CHANGE,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,SNPEFF_EXON_ID,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,Samples,dbSNP${dbsnpLatestVersionNumber}.AF,dbSNP${dbsnpLatestVersionNumber}.G5,dbSNP${dbsnpLatestVersionNumber}.G5A,dbSNP${dbsnpLatestVersionNumber}.KGPROD,dbSNP${dbsnpLatestVersionNumber}.KGPilot1,dbSNP${dbsnpLatestVersionNumber}.KGPilot123,dbSNP${dbsnpLatestVersionNumber}.KGVAL,dbSNP${dbsnpLatestVersionNumber}.dbSNPBuildID \
-format GT

echo -e "Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAllele_balance\tAllele_count\tAllele_number\tBaseCounts_A_C_G_T\tDepth\tGC_content\tMapping_quality\tQuality_by_depth\tStrand_ballance\tsnpEff_amino_acid_change\tsnpEff_codon_change\tsnpEff_effect\tsnpEff_exon_ID\tsnpEff_functional_class\tsnpEff_gene_biotype\tsnpEff_gene_name\tsnpEff_impact\tsnpEff_transcript_ID\tSample\tdbSNP${dbsnpLatestVersionNumber}_allele_frequency\t1KG_>5%_MAF_in_>1_populations\t1KG_>5%_MAF_in_each_and_all_populations\tDiscovered_in_1KG_production_phase\tDiscovered_in_1KG_pilot1\tDiscovered_in_1KG_all_pilots\tDiscovered_in_1KG_and_validated_by_second_method\tFirst_included_in_dbSNP_release\tGenotype" > ${snpsfinalvcftable}

sed '2,$!d' ${snpstmpvcftable} >> ${snpsfinalvcftable}


# get SNP statistics
perl ${snpannotationstatspl} \
-vcf_table ${snpsfinalvcftable} \
-typefile ${snpsfinalvcftabletype} \
-classfile ${snpsfinalvcftableclass} \
-impactfile ${snpsfinalvcftableimpact} \
-snptypes INTERGENIC,UPSTREAM,UTR_5_PRIME,UTR_5_DELETED,START_GAINED,SPLICE_SITE_ACCEPTOR,SPLICE_SITE_DONOR,START_LOST,SYNONYMOUS_START,CDS,GENE,TRANSCRIPT,EXON,EXON_DELETED,NON_SYNONYMOUS_CODING,SYNONYMOUS_CODING,FRAME_SHIFT,CODON_CHANGE,CODON_INSERTION,CODON_CHANGE_PLUS_CODON_INSERTION,CODON_DELETION,CODON_CHANGE_PLUS_CODON_DELETION,STOP_GAINED,SYNONYMOUS_STOP,STOP_LOST,INTRON,UTR_3_PRIME,UTR_3_DELETED,DOWNSTREAM,INTRON_CONSERVED,INTERGENIC_CONSERVED,INTRAGENIC,RARE_AMINO_ACID,NON_SYNONYMOUS_START \
-snpclasses MISSENSE,NONSENSE,NONE,SILENT \
-snpimpacts HIGH,LOW,MODERATE,MODIFIER