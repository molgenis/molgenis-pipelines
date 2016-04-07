#MOLGENIS walltime=35:59:00 mem=6gb ppn=8

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffCallsHtml
#string snpEffCallsVcf
#string snpEffGenesTxt
#string project
#string logsDir
#string projectVariantsMergedSorted
#string tmpDataDir
#string snpEffVersion
#string javaVersion

sleep 5

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
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load GATK module
${stage} ${javaVersion}
${stage} ${snpEffVersion}
${checkStage}

#Run snpEff
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$EBROOTSNPEFF/snpEff.jar \
eff \
-v \
-c $EBROOTSNPEFF/snpEff.config \
-i vcf \
-o gatk \
GRCh37.75 \
-stats ${tmpSnpEffCallsHtml} \
${projectVariantsMergedSorted} \
> ${tmpSnpEffCallsVcf}

    mv ${tmpSnpEffCallsHtml} ${snpEffCallsHtml}
    mv ${tmpSnpEffCallsVcf} ${snpEffCallsVcf}
    mv ${tmpSnpEffGenesTxt} ${snpEffGenesTxt}

