#MOLGENIS walltime=35:59:00 mem=6gb
#string tmpName
#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string dbNSFP
#string intermediateDir
#string variantAnnotatorSampleOutputSnpsFilteredVcf
#string dbNSFPSampleVcf
#string tmpDataDir
#string project
#string logsDir
#string javaVersion
#string snpEffVersion


#optional annotation columns 
###Build 37 -->  dbnsfp 2.7
#chr,pos(1-coor),ref,alt,aaref,aaalt,rs_dbSNP141,hg18_pos(1-coor),hg38_chr,hg38_pos,
#genename,Uniprot_acc,Uniprot_id,Uniprot_aapos,Interpro_domain,cds_strand,refcodon,
#SLR_test_statistic,codonpos,fold-degenerate,Ancestral_allele,Ensembl_geneid,Ensembl_transcriptid,
#aapos,aapos_SIFT,aapos_FATHMM,SIFT_score,SIFT_converted_rankscore,SIFT_pred,Polyphen2_HDIV_score,
#Polyphen2_HDIV_rankscore,Polyphen2_HDIV_prePolyphen2_HVAR_score,Polyphen2_HVAR_rankscore,
#Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,MutationTaster_score,
#MutationTaster_converted_rankscore,MutationTaster_pred,MutationAssessor_score,
#MutationAssessor_rankscore,MutationAssessor_pred,FATHMM_score,FATHMM_rankscore,FATHMM_pred,
#RadialSVM_score,RadialSVM_rankscore,RadialSVM_pred,LR_score,LR_rankscore,LR_pred,
#Reliability_index,VEST3_score,VEST3_rankscore,CADD_raw,CADD_raw_rankscore,CADD_phred,
#GERP++_NR,GERP++_RS,GERP++_RS_rankscore,phyloP46way_primate,phyloP46way_primate_rankscore,
#phyloP46way_placental,phyloP46way_placental_rankscore,phyloP100way_vertebrate,
#phyloP100way_vertebrate_rankscore,phastCons46way_primate,phastCons46way_primate_rankscore,
#phastCons46way_placental,phastCons46way_placental_rankscore,phastCons100way_vertebrate,
#phastCons100way_vertebrate_rankscore,SiPhy_29way_pi,SiPhy_29way_logOdds,
#SiPhy_29way_logOdds_rankscore,LRT_Omega,UniSNP_ids,1000Gp1_AC,1000Gp1_AF,1000Gp1_AFR_AC,
#1000Gp1_AFR_AF,1000Gp1_EUR_AC,1000Gp1_EUR_AF,1000Gp1_AMR_AC,1000Gp1_AMR_AF,1000Gp1_ASN_AC,
#1000Gp1_ASN_AF,ESP6500_AA_AF,ESP6500_EA_AF ,ARIC5606_AA_AC,ARIC5606_AA_AF,ARIC5606_EA_AC,
#ARIC5606_EA_AF,clinvar_rs,clinvar_clnsig,clinvar_trait

#### Build 38 --> dbnsfp v3 and higher ####
##chr,pos(1-based),ref,alt,aaref,aaalt,rs_dbSNP142,hg19_chr,hg19_pos(1-based),hg18_chr,hg18_pos(1-based),
#genename,cds_strand,refcodon,codonpos,codon_degeneracy,Ancestral_allele,AltaiNeandertal,Denisova,Ensembl_geneid,
#Ensembl_transcriptid,Ensembl_proteinid,aapos,SIFT_score,SIFT_converted_rankscore,SIFT_pred,Uniprot_acc_Polyphen2,
#Uniprot_id_Polyphen2,Uniprot_aapos_Polyphen2,Polyphen2_HDIV_score,Polyphen2_HDIV_rankscore,Polyphen2_HDIV_pred,
#Polyphen2_HVAR_score,Polyphen2_HVAR_rankscore,Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,LRT_Omega,
#MutationTaster_score,MutationTaster_converted_rankscore,MutationTaster_pred,MutationTaster_model,MutationTaster_AAE,
#Uniprot_id_MutationAssessor,Uniprot_variant_MutationAssessor,MutationAssessor_score,MutationAssessor_rankscore,
#MutationAssessor_pred,FATHMM_score,FATHMM_converted_rankscore,FATHMM_pred,PROVEAN_score,PROVEAN_converted_rankscore,
#PROVEAN_pred,Transcript_id_VEST3,Transcript_var_VEST3,VEST3_score,VEST3_rankscore,CADD_raw,CADD_raw_rankscore,
#CADD_phred,MetaSVM_score,MetaSVM_rankscore,MetaSVM_pred,MetaLR_score,MetaLR_rankscore,MetaLR_pred,Reliability_index,
#GERP++_NR,GERP++_RS,GERP++_RS_rankscore,phyloP7way_vertebrate,phyloP7way_vertebrate_rankscore,phastCons7way_vertebrate,
#phastCons7way_vertebrate_rankscore,SiPhy_29way_pi,SiPhy_29way_logOdds,SiPhy_29way_logOdds_rankscore,1000Gp3_AC,
#1000Gp3_AF,1000Gp3_AFR_AC,1000Gp3_AFR_AF,1000Gp3_EUR_AC,1000Gp3_EUR_AF,1000Gp3_AMR_AC,1000Gp3_AMR_AF,1000Gp3_EAS_AC,
#1000Gp3_EAS_AF,1000Gp3_SAS_AC,1000Gp3_SAS_AF,TWINSUK_AC,TWINSUK_AF,ALSPAC_AC,ALSPAC_AF,ESP6500_AA_AC,ESP6500_AA_AF,
#ESP6500_EA_AC,ESP6500_EA_AF,ExAC_AC,ExAC_AF,ExAC_Adj_AC,ExAC_Adj_AF,ExAC_AFR_AC,ExAC_AFR_AF,ExAC_AMR_AC,ExAC_AMR_AF,
#ExAC_EAS_AC,ExAC_EAS_AF,ExAC_FIN_AC,ExAC_FIN_AF,ExAC_NFE_AC,ExAC_NFE_AF,ExAC_SAS_AC,ExAC_SAS_AF,clinvar_rs,
#clinvar_clnsig,clinvar_trait,Interpro_domain
#



sleep 5

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

#Load module
${stage} ${javaVersion}
${stage} ${snpEffVersion}
${checkStage}

makeTmpDir ${dbNSFPSampleVcf}
tmpDbNSFPSampleVcf=${MC_tmpFile}

#Run dbNSFP
java -Djava.io.tmpdir=${tempDir} -Xmx4g -XX:ParallelGCThreads=2 -jar \
${EBROOTSNPEFF}/SnpSift.jar \
dbnsfp \
-a \
-db ${dbNSFP} \
-v \
-f Ensembl_geneid,GERP++_RS,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,SIFT_score,CADD_raw,CADD_raw_rankscore,CADD_phred,FATHMM_score,SiPhy_29way_logOdds,phastCons100way_vertebrate,1000Gp1_EUR_AF,ESP6500_EA_AF \
${variantAnnotatorSampleOutputSnpsFilteredVcf} > ${tmpDbNSFPSampleVcf}

FIRSTLINE=`head -1 ${tmpDbNSFPSampleVcf}`

if [[ "$FIRSTLINE" == *"hg38"* ]]
then
	sed '1d' ${tmpDbNSFPSampleVcf} > ${dbNSFPSampleVcf}
	echo "removed first line of ${tmpDbNSFPSampleVcf} and moved file to ${dbNSFPSampleVcf}"
else
	mv ${tmpDbNSFPSampleVcf} ${dbNSFPSampleVcf}
	echo "mv ${tmpDbNSFPSampleVcf} ${dbNSFPSampleVcf}"

fi


