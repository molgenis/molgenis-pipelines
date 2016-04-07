#MOLGENIS walltime=43:59:00 mem=6gb ppn=1

#Parameter mapping
#string tmpName
#string vcf2Table
#string variantsFinalProjectVcfTable
#string tmpDataDir
#string logsDir
#string projectPrefix
#string intermediateDir
#list externalSampleID
#string	project
 
makeTmpDir ${variantsFinalProjectVcfTable}
tmpVariantsFinalProjectVcfTable=${MC_tmpFile}
module load ngs-utils
module list

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

INPUTS=()
for SampleID in "${externalSampleID[@]}"
do
        array_contains INPUTS "$SampleID" || INPUTS+=("$SampleID")    # If bamFile does not exist in array add it
done

filter="AC,AF,AN,BaseCounts,BaseQRankSum,ClippingRankSum,DB,dbNSFP_GERP++_RS,dbNSFP_SiPhy_29way_logOdds,dbNSFP_Ensembl_geneid,dbNSFP_CADD_phred,dbNSFP_FATHMM_score,dbNSFP_CADD_raw,dbNSFP_phastCons100way_vertebrate,dbNSFP_Polyphen2_HDIV_pred,dbNSFP_CADD_raw_rankscore,dbNSFP_1000Gp1_EUR_AF,dbNSFP_ESP6500_EA_AF,dbNSFP_Polyphen2_HVAR_pred,DP,FS,MQ,MQ0,MQRankSum,QD,ReadPosRankSum,SNPEFF_CODON_CHANGE,SNPEFF_EFFECT,SNPEFF_FUNCTIONAL_CLASS,SNPEFF_GENE_BIOTYPE,SNPEFF_GENE_NAME,SNPEFF_IMPACT,SNPEFF_TRANSCRIPT_ID,VariantType,Samples"

for externalID in "${INPUTS[@]}"
do
	AS+="${externalID},"
	vcfTable=${intermediateDir}/${externalID}.final.vcf.table	
	tmpVcfTable=${vcfTable}.tmp

	####Transform VCF file into tabular file####
	${vcf2Table} \
	-vcf ${intermediateDir}/${externalID}.final.vcf \
	-output ${tmpVcfTable} \
	-filter ${filter} \
	-sample ${externalID}

	mv ${tmpVcfTable} ${vcfTable}
	echo "mv ${tmpVcfTable} ${vcfTable}"
done

ALLSAMPLESINONE=`echo ${AS%?}`

####Transform VCF file into tabular file####
${vcf2Table} \
-vcf ${projectPrefix}.final.vcf \
-output ${tmpVariantsFinalProjectVcfTable} \
-filter ${filter} \
-sample ${ALLSAMPLESINONE}

mv ${tmpVariantsFinalProjectVcfTable} ${variantsFinalProjectVcfTable}
echo "mv ${tmpVariantsFinalProjectVcfTable} ${variantsFinalProjectVcfTable}"
