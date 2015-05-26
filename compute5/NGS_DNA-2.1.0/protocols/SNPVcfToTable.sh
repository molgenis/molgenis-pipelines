#MOLGENIS walltime=23:59:00 mem=6gb ppn=1

#Parameter mapping
#string vcf2tabpl
#string variantsFinalVcf
#string variantsFinalVcfTable
#string variantType
#string tmpDataDir
#string project
#string intermediateDir


#Echo parameter values
echo "vcf2tabpl: ${vcf2tabpl}"
echo "variantsFinalVcf: ${variantsFinalVcf}"
echo "variantsFinalVcfTable: ${variantsFinalVcfTable}"

makeTmpDir ${variantsFinalVcfTable}
tmpvariantsFinalVcfTable=${MC_tmpFile}

# adjust the columnheader filtering according to the snp or indel imput vcf.  
filter="ABHom,ABHet,AC,AF,AN,BaseCounts,DB,DP,Dels,FS,HaplotypeScore,MLEAC,MLEAF,MQ,MQ0,OND,QD,SNPEFF_EFFECT,SNPEFF_EXON_ID,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,VariantType"

header="Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tABHom\tABHet\tAC\tAF\tAN\tBaseCounts\tDB\tDP\tDels\tFS\tHaplotypeScore\tMLEAC\tMLEAF\tMQ\tMQ0\tOND\tQD\tSNPEFF_EFFECT\tSNPEFF_EXON_ID\tSNPEFF_FUNCTIONAL_CLASS\tSNPEFF_GENE_BIOTYPE\tSNPEFF_GENE_NAME\tSNPEFF_IMPACT\tSNPEFF_TRANSCRIPT_ID\tVariantType\tSamples"

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${variantsFinalVcf} \
-output ${tmpvariantsFinalVcfTable} \
-filter ${filter} \
-format GT

echo -e ${header} > ${tmpvariantsFinalVcfTable}.tmp

sed '2,$!d' ${tmpvariantsFinalVcfTable} >> ${tmpvariantsFinalVcfTable}.tmp

mv ${tmpvariantsFinalVcfTable}.tmp ${variantsFinalVcfTable}

