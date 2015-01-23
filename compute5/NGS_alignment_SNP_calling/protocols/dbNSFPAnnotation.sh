#MOLGENIS walltime=35:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string dbNSFP
#string intermediateDir
#string variantAnnotatorOutputSnpsVcf
#string outputDbNSFPVcf
#string tmpDataDir
#string project

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "outputDbNSFPVcf: ${outputDbNSFPVcf}"

#optional annotation columns
#chr,pos(1-coor),ref,alt,aaref,aaalt,hg18_pos(1-coor),genename,Uniprot_acc,Uniprot_id,Uniprot_aapos,
#Interpro_domain,cds_strand,refcodon,SLR_test_statistic,codonpos,fold-degenerate,Ancestral_allele,
#Ensembl_geneid,Ensembl_transcriptid,aapos,aapos_SIFT,aapos_FATHMM,SIFT_score,SIFT_converted_rankscore,
#SIFT_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_rankscore,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,
#Polyphen2_HVAR_rankscore,Polyphen2_HVAR_pred,LRT_score,LRT_converted_rankscore,LRT_pred,
#MutationTaster_score,MutationTaster_converted_rankscore,MutationTaster_pred,MutationAssessor_score,
#MutationAssessor_rankscore,MutationAssessor_pred,FATHMM_score,FATHMM_rankscore,FATHMM_pred,
#RadialSVM_score,RadialSVM_rankscore,RadialSVM_pred,LR_score,LR_rankscore,LR_pred,Reliability_index,
#CADD_raw,CADD_raw_rankscore,CADD_phred,GERP++_NR,GERP++_RS,GERP++_RS_rankscore,phyloP46way_primate,
#phyloP46way_primate_rankscore,phyloP46way_placental,phyloP46way_placental_rankscore,
#phyloP100way_vertebrate,phyloP100way_vertebrate_rankscore,phastCons46way_primate,phastCons46way_primate_rankscore,
#phastCons46way_placental,phastCons46way_placental_rankscore,phastCons100way_vertebrate,
#phastCons100way_vertebrate_rankscore,SiPhy_29way_pi,SiPhy_29way_logOdds,SiPhy_29way_logOdds_rankscore,LRT_Omega,
#UniSNP_ids,1000Gp1_AC,1000Gp1_AF,1000Gp1_AFR_AC,1000Gp1_AFR_AF,1000Gp1_EUR_AC,1000Gp1_EUR_AF,1000Gp1_AMR_AC,
#1000Gp1_AMR_AF,1000Gp1_ASN_AC,1000Gp1_ASN_AF,ESP6500_AA_AF,ESP6500_EA_AF


sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load module
${stage} jdk/1.7.0_51
${stage} snpEff/3.6c
${checkStage}

makeTmpDir ${outputDbNSFPVcf}
tmpOutputDbNSFPVcf=${MC_tmpFile}

#Run dbNSFP
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/SnpSift.jar \
dbnsfp \
-a \
-v ${dbNSFP} \
-f Ensembl_geneid,GERP++_RS,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,SIFT_score,CADD_raw,CADD_raw_rankscore,CADD_phred,FATHMM_score,SiPhy_29way_logOdds,phastCons100way_vertebrate,1000Gp1_EUR_AF,ESP6500_EA_AF \
${variantAnnotatorOutputSnpsVcf} \
> ${tmpOutputDbNSFPVcf}

echo -e "\ndbNSFPSnpEffAnnotation finished successfully. Moving temp files to final.\n\n"
mv ${tmpOutputDbNSFPVcf} ${outputDbNSFPVcf}

