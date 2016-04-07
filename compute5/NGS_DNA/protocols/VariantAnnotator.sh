#MOLGENIS walltime=35:59:00 mem=15gb ppn=8

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string tempDir
#string intermediateDir
#string snpEffCallsHtml
#string snpEffCallsVcf
#string snpEffGenesTxt
#string indexFile
#string indexFileFastaIndex
#string capturedIntervals
#string projectVariantsMergedSorted
#string logsDir
#string snpEffCallsSortedVcf
#string variantAnnotatorOutputVcf
#string project
#string projectVariantsMergedSortedSorted

#list externalSampleID
#string tmpDataDir
#string sortVCFpl
#string gatkVersion
#string gatkJar
#string snpEffVersion
#string javaVersion
#string dbSNPDir

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
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

for externalID in "${externalSampleID[@]}"
do
        array_contains SAMPLES "$externalID" || SAMPLES+=("$externalID")    # If bamFile does not exist in array add it
done

for sample in "${SAMPLES[@]}"
do
  echo "sample: ${sample}"		
  INPUTS+=("-I ${intermediateDir}/${sample}.merged.dedup.bam")
done

#Load GATK module
${stage} ${javaVersion}
${stage} ${gatkVersion}
${stage} ${snpEffVersion}
${stage} ngs-utils

${checkStage}

#sort VCf file: ${projectVariantsMergedSorted} 
${sortVCFpl} \
-fastaIndexFile ${indexFileFastaIndex} \
-inputVCF ${projectVariantsMergedSorted} \
-outputVCF ${projectVariantsMergedSortedSorted}

#sort VCf file: ${snpEffCallsVcf}
${sortVCFpl} \
-fastaIndexFile ${indexFileFastaIndex} \
-inputVCF ${snpEffCallsVcf} \
-outputVCF ${snpEffCallsSortedVcf}

java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx8g -jar \
${EBROOTGATK}/${gatkJar} \
-T VariantAnnotator \
-R ${indexFile} \
${INPUTS[@]} \
-A SnpEff \
-A AlleleBalance \
-A BaseCounts \
-A BaseQualityRankSumTest \
-A ChromosomeCounts \
-A Coverage \
-A FisherStrand \
-A LikelihoodRankSumTest \
-A MappingQualityRankSumTest \
-A MappingQualityZeroBySample \
-A ReadPosRankSumTest \
-A RMSMappingQuality \
-A QualByDepth \
-A VariantType \
-A AlleleBalanceBySample \
-A DepthPerAlleleBySample \
-A SpanningDeletions \
--disable_auto_index_creation_and_locking_when_reading_rods \
-D ${dbSNPDir}/dbsnp_137.b37.vcf \
--variant ${projectVariantsMergedSorted} \
--snpEffFile ${snpEffCallsSortedVcf} \
-L ${capturedIntervals} \
-o ${variantAnnotatorOutputVcf} \
-nt 8

