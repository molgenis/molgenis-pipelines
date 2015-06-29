#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string variantAnnotatorSampleOutputSnpsVcf
#string variantAnnotatorSampleOutputSnpsFilteredVcf
#string tmpDataDir
#string project

#sstring SNPDir

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${array[@]}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

INPUTS=()

#Load GATK module
${stage} GATK/${gatkVersion}
${checkStage}

makeTmpDir ${variantAnnotatorSampleOutputSnpsFilteredVcf}
tmpVariantAnnotatorSampleOutputSnpsFilteredVcf=${MC_tmpFile}

#Run GATK VariantFiltration to filter called SNPs on 


java -jar GenomeAnalysisTK.jar \ 
    -T VariantRecalibrator \ 
    -R reference.fa \ 
    -input raw_variants.vcf \ 
    -resource:hapmap,known=false,training=true,truth=true,prior=15.0 hapmap.vcf \ 
    -resource:omni,known=false,training=true,truth=true,prior=12.0 omni.vcf \ 
    -resource:1000G,known=false,training=true,truth=false,prior=10.0 1000G.vcf \ 
    -resource:dbsnp,known=true,training=false,truth=false,prior=2.0 dbsnp.vcf \ 
    -an DP \ 
    -an QD \ 
    -an FS \ 
    -an SOR \ 
    -an MQ \
    -an MQRankSum \ 
    -an ReadPosRankSum \ 
    -an InbreedingCoeff \
    -mode SNP \ 
    -tranche 100.0 -tranche 99.9 -tranche 99.0 -tranche 90.0 \ 
    -recalFile recalibrate_SNP.recal \ 
    -tranchesFile recalibrate_SNP.tranches \ 
    -rscriptFile recalibrate_SNP_plots.R




java -XX:ParallelGCThreads=4 -Xmx8g -Xms6g -jar $GATK_HOME/${gatkJar} \
-T VariantFiltration \
-R ${indexFile} \
-o ${tmpVariantAnnotatorSampleOutputSnpsFilteredVcf} \
--variant ${variantAnnotatorSampleOutputSnpsVcf} \
--filterExpression "QD < 2.0" \
--filterName "filterQD" \
--filterExpression "MQ < 25.0" \
--filterName "filterMQ" \
--filterExpression "FS > 60.0" \
--filterName "filterFS" \
--filterExpression "MQRankSum < -12.5" \
--filterName "filterMQRankSum" \
--filterExpression "ReadPosRankSum < -8.0" \
--filterName "filterReadPosRankSum"

echo -e "\nVariantFiltering finished succesfull. Moving temp files to final.\n\n"
mv ${tmpVariantAnnotatorSampleOutputSnpsFilteredVcf} ${variantAnnotatorSampleOutputSnpsFilteredVcf}
