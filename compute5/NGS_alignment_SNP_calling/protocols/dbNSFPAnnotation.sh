#MOLGENIS walltime=35:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string jdkVersion
#string snpEffVersion
#string snpSiftJar
#string tempDir
#string intermediateDir
#string inputVcf
#string outputTmpDBnsfpVcf   tmpSnpEffDBnsfpCallsVcf
#string outputTmpDBnsfpVcfIdx tmpSnpEffDBnsfpCallsVcfIdx 
#string outputDBnsfpVcf snpEffDBnsfpCallsVcf
#string outputDBnsfpVcfIdx snpEffDBnsfpCallsVcfIdx

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "jdkVersion: ${jdkVersion}"
echo "snpEffVersion: ${snpEffVersion}"
echo "snpSiftJar: ${snpSiftJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "inputVcf: ${inputVcf}"
echo "outputTmpDBnsfpVcf: ${outputTmpDBnsfpVcf}"
echo "outputTmpDBnsfpVcfIdx: ${outputTmpDBnsfpVcfIdx}"
echo "outputDBnsfpVcf: ${outputDBnsfpVcf}"
echo "outputDBnsfpVcfIdx: ${outputDBnsfpVcfIdx}"

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Check if output exists
alloutputsexist \
"${outputDBnsfpVcfIdx}" \
"${outputDBnsfpVcf}"


#Load module
${stage} jdk/${jdkVersion}
${stage} snpEff/${snpEffVersion}
${checkStage}


#Run dbNSFP
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/${snpSiftJar} \
dbnsfp \
-a \
-v /gcc/groups/gcc-guest/tmp02/gcc-guest23/dbNSFPv2_4/dbNSFP2.4.txt.gz \
-f Ensembl_geneid,GERP++_RS,Polyphen2_HDIV_pred,Polyphen2_HVAR_pred,SIFT_score,CADD_raw,FATHMM_score,SiPhy_29way_logOdds,phastCons100way_vertebrate,1000Gp1_EUR_AF,ESP6500_EA_AF \
${inputVcf} \
> ${outputTmpDBnsfpVcf}

echo -e "\ndbNSFPSnpEffAnnotation finished successfully. Moving temp files to final.\n\n"
mv ${outputTmpDBnsfpVcf} ${outputDBnsfpVcf}
mv ${outputTmpDBnsfpVcfIdx} ${outputDBnsfpVcfIdx}

echo -e "\nFailed to move dbNSFPAnnotation results to ${intermediateDir}\n\n"
exit -1
