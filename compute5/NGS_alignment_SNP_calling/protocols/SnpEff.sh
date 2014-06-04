#MOLGENIS walltime=35:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string ProjectVariantCallsVcf
#string snpEffCallsHtml
#string snpEffCallsVcf
#string snpEffGenesTxt

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "ProjectVariantCalls: ${ProjectVariantCalls}"
echo "snpEffCallsHtml: ${snpEffCallsHtml}"
echo "snpEffCallsVcf: ${snpEffCallsVcf}"
echo "snpEffGenesTxt: ${snpEffGenesTxt}"

sleep 10

makeTmpDir ${snpEffCallsHtml}
tmpSnpEffCallsHtml=${MC_tmpFile}

makeTmpDir ${snpEffCallsVcf}
tmpSnpEffCallsVcf=${MC_tmpFile}

makeTmpDir ${snpEffGenesTxt}
tmpSnpEffGenesTxt=${MC_tmpFile}

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
"${snpEffCallsHtml}" \
"${snpEffCallsVcf}" \
"${snpEffGenesTxt}"


#Load GATK module
${stage} jdk/1.7.0_25
${stage} GATK/2.7-4-g6f46d11
${stage} snpEff/2_0_5
${checkStage}


#Run snpEff
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/snpEff.jar \
eff \
-v \
-c $SNPEFF_HOME/snpEff.config \
-i vcf \
-o vcf \
GRCh37.64 \
-onlyCoding true \
-stats ${tmpSnpEffCallsHtml} \
${ProjectVariantCallsVcf} \
> ${tmpSnpEffCallsVcf}
    echo -e "\nsnpEffAnnotation finished successfully. Moving temp files to final.\n\n"
    mv ${tmpSnpEffCallsHtml} ${snpEffCallsHtml}
    mv ${tmpSnpEffCallsVcf} ${snpEffCallsVcf}
    mv ${tmpSnpEffGenesTxt} ${snpEffGenesTxt}
    putFile "${snpEffCallsHtml}"
    putFile "${snpEffCallsVcf}"
    putFile "${snpEffGenesTxt}"
