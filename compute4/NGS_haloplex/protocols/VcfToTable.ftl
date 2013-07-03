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
java -jar -Xmx10g /target/gpfs2/gcc/tools/GenomeAnalysisTK-2.5-2-gf57256b/GenomeAnalysisTK.jar \
-T VariantsToTable \
-R ${indexfile} \
-V ${snpsfinalvcf} \
-F CHROM -F POS -F ID -F REF -F ALT -F QUAL -F FILTER \
-F AC -F AN -F BaseCounts -F DP -F GC -F MQ -F QD -F SNPEFF_AMINO_ACID_CHANGE -F SNPEFF_CODON_CHANGE \
-F SNPEFF_EFFECT -F SNPEFF_EXON_ID -F SNPEFF_FUNCTIONAL_CLASS -F SNPEFF_GENE_BIOTYPE \
-F SNPEFF_GENE_NAME -F SNPEFF_IMPACT -F SNPEFF_TRANSCRIPT_ID \
-GF GT -GF AB \
--allowMissingData \
-o ${snpstmpvcftable}

echo -e "Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAllele_count\tAllele_number\tBaseCounts_A_C_G_T\tDepth\tGC_content\tMapping_quality\tQuality_by_depth\tsnpEff_amino_acid_change\tsnpEff_codon_change\tsnpEff_effect\tsnpEff_exon_ID\tsnpEff_functional_class\tsnpEff_gene_biotype\tsnpEff_gene_name\tsnpEff_impact\tsnpEff_transcript_ID\tGenotype\tAllele_balance" > ${snpsfinalvcftable}

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