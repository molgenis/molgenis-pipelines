#MOLGENIS walltime=23:59:00 mem=6gb ppn=1

#Parameter mapping
#string vcf2tabpl
#string variantsFinalVcf
#string variantsFinalVcfTable
#string tmpDataDir
#string project

#Echo parameter values
echo "vcf2tabpl: ${vcf2tabpl}"
echo "variantsFinalVcf: ${variantsFinalVcf}"
echo "variantsFinalVcfTable: ${variantsFinalVcfTable}"

makeTmpDir ${variantsFinalVcfTable}
tmpvariantsFinalVcfTable=${MC_tmpFile}

# adjust the columnheader filtering according to the snp or indel imput vcf.  

filter="AC,AF,AN,BaseCounts,BaseQRankSum,ClippingRankSum,DB,DP,FS,MQ,MQ0,MQRankSum,QD,ReadPosRankSum,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,VariantType,Samples"

header="Chromosome\tPosition\tdbSNPid\tReference_allele\tAlternative_allele\tQuality\tFilter\tAC\tAF\tAN\tBaseCounts\tBaseQRankSum\tClippingRankSum\tDB\tDP\tFS\tMQ\tMQ0\tMQRankSum\tQD\tReadPosRankSum\tSNPEFF_CODON_CHANGE\tSNPEFF_EFFECT\tSNPEFF_FUNCTIONAL_CLASS\tSNPEFF_GENE_BIOTYPE\tSNPEFF_GENE_NAME\tSNPEFF_IMPACT\tSNPEFF_TRANSCRIPT_ID\tVariantType\tSamples" 

####Transform VCF file into tabular file####
perl ${vcf2tabpl} \
-vcf ${variantsFinalVcf} \
-output ${tmpvariantsFinalVcfTable}.tmp \
-filter ${filter} \
-format GT

echo -e ${header} > ${tmpvariantsFinalVcfTable}

sed '2,$!d' ${tmpvariantsFinalVcfTable}.tmp >> ${tmpvariantsFinalVcfTable}

mv ${tmpvariantsFinalVcfTable} ${variantsFinalVcfTable}
