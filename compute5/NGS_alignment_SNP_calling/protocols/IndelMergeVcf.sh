#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string intermediateDir
#string project
#string projectIndelsMerged
#string externalSampleID
#string indexFile
#string indexFileFastaIndex
#string sampleIndelsPindelGATKMerged
#string baitIntervals
#string seqType
#string gatkVersion
#string mergeSVspl
#string sortVCFpl

 
#Load GATK,bcftools,tabix module
${stage} GATK/${gatkVersion}
${checkStage}

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"

makeTmpDir ${sampleIndelsPindelGATKMerged}
tmp_sampleIndelsPindelGATKMerged=${MC_tmpFile}

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

echo "running GATK : SelectVariants"

#Select a sample and restrict the output vcf to a set of intervals:
 java -Xmx2g -jar $GATK_HOME/GenomeAnalysisTK.jar \
   -R ${indexFile} \
   -T SelectVariants \
   --variant ${projectIndelsMerged} \
   -o ${intermediateDir}/${externalSampleID}.indels.GATK.vcf \
   -L ${baitIntervals} \
   -sn ${externalSampleID}
if [ ${seqType} == "PE" ]
then

#Merge Pindel en GATK called indels

perl ${mergeSVspl} \
-pindelVCF ${intermediateDir}/${externalSampleID}.output.pindel.merged.vcf \
-unifiedGenotyperVCF ${intermediateDir}/${externalSampleID}.indels.GATK.vcf \
-outputVCF ${tmp_sampleIndelsPindelGATKMerged}.UNSORTED

perl ${sortVCFpl} \
-fastaIndexFile ${indexFileFastaIndex} \
-inputVCF ${tmp_sampleIndelsPindelGATKMerged}.UNSORTED \
-outputVCF ${tmp_sampleIndelsPindelGATKMerged}

#add header INFO annotation for PindelREF and PindelALT  
sed -i '10i\##INFO=<ID=PindelREF,Number=1,Type=String,Description="PindelREF">' ${tmp_sampleIndelsPindelGATKMerged}
sed -i '10i\##INFO=<ID=PindelALT,Number=1,Type=String,Description="PindelALT">' ${tmp_sampleIndelsPindelGATKMerged}


mv ${tmp_sampleIndelsPindelGATKMerged} ${sampleIndelsPindelGATKMerged}

elif [ ${seqType} == "SR" ]
then
	cp ${intermediateDir}/${externalSampleID}.indels.GATK.vcf ${sampleIndelsPindelGATKMerged}
fi
