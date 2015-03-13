#MOLGENIS walltime=35:59:00 mem=4gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffCallsHtml
#string snpEffIndelsVcf
#string snpEffGenesTxt
#string sampleIndelsPindelGATKMerged
#string tmpDataDir
#string project
#string gatkVersion
#string snpEffVersion
#string javaVersion


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "snpEffCallsHtml: ${snpEffCallsHtml}"
echo "snpEffIndelsVcf: ${snpEffIndelsVcf}"
echo "snpEffGenesTxt: ${snpEffGenesTxt}"

sleep 10

makeTmpDir ${snpEffCallsHtml}
tmpSnpEffCallsHtml=${MC_tmpFile}

makeTmpDir ${snpEffIndelsVcf}
tmpSnpEffIndelsVcf=${MC_tmpFile}

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

#Load GATK module
${stage} jdk/${javaVersion}
${stage} GATK/${gatkVersion}
${stage} snpEff/${snpEffVersion}
${checkStage}

#Run snpEff
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$SNPEFF_HOME/snpEff.jar \
eff \
-v \
-c $SNPEFF_HOME/snpEff.config \
-i vcf \
-o gatk \
GRCh37.75 \
-stats ${tmpSnpEffCallsHtml} \
${sampleIndelsPindelGATKMerged} \
> ${tmpSnpEffIndelsVcf}

#${intermediateDir}${project}.indels.calls.mergedAllVcf.vcf \

    mv ${tmpSnpEffCallsHtml} ${snpEffCallsHtml}
    mv ${tmpSnpEffIndelsVcf} ${snpEffIndelsVcf}
    mv ${tmpSnpEffGenesTxt} ${snpEffGenesTxt}
chmod -R g+rwX $intermediateDir
