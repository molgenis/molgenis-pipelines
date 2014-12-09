#MOLGENIS walltime=35:59:00 mem=4gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffSNPCallsHtml
#string snpEffSnpsVcf
#string snpEffSNPGenesTxt
#string inputVcf
#string tmpDataDir
#string project

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "snpEffSNPCallsHtml: ${snpEffSNPCallsHtml}"
echo "snpEffSNPCallsVcf: ${snpEffSnpsVcf}"
echo "snpEffSNPGenesTxt: ${snpEffSNPGenesTxt}"

sleep 10

makeTmpDir ${snpEffSNPCallsHtml}
tmpSnpEffSNPCallsHtml=${MC_tmpFile}

makeTmpDir ${snpEffSnpsVcf}
tmpsnpEffSnpsVcf=${MC_tmpFile}

makeTmpDir ${snpEffSNPGenesTxt}
tmpSnpEffSNPGenesTxt=${MC_tmpFile}

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

#Load GATK module
${stage} jdk/1.7.0_51
${stage} GATK/3.1-1-g07a4bf8
${stage} snpEff/3.6c
${checkStage}

#Run snpEff
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/snpEff.jar \
eff \
-v \
-c $SNPEFF_HOME/snpEff.config \
-i vcf \
-o gatk \
GRCh37.69 \
-stats ${tmpSnpEffSNPCallsHtml} \
${inputVcf} \
> ${tmpsnpEffSnpsVcf}

    mv ${tmpSnpEffSNPCallsHtml} ${snpEffSNPCallsHtml}
    mv ${tmpsnpEffSnpsVcf} ${snpEffSnpsVcf}
    mv ${tmpSnpEffSNPGenesTxt} ${snpEffSNPGenesTxt}
