#MOLGENIS walltime=23:59:00 mem=6gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string intermediateDir
#string project
#string projectIndelsMerged
#string externalSampleID
#string indexFile
#string sampleIndelsPindelGATKMerged
#string targetIntervals
 
#Load GATK,bcftools,tabix module
${stage} GATK/3.2-2-gec30cee
module load bcftools/0.2.0
module load tabix/0.2.6
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
   -L ${targetIntervals} \
   -sn ${externalSampleID}

#gzip and make indexfiles for bcftools
bgzip -c ${intermediateDir}/${externalSampleID}.indels.GATK.vcf > ${intermediateDir}/${externalSampleID}.indels.GATK.vcf.gz
bgzip -c ${intermediateDir}/${externalSampleID}.output.pindel.merged.vcf > ${intermediateDir}/${externalSampleID}.output.pindel.merged.vcf.gz
tabix -p vcf ${intermediateDir}/${externalSampleID}.indels.GATK.vcf.gz
tabix -p vcf ${intermediateDir}/${externalSampleID}.output.pindel.merged.vcf.gz

echo "running BCFTools : merge"
bcftools merge \
${intermediateDir}/${externalSampleID}.indels.GATK.vcf.gz \
${intermediateDir}/${externalSampleID}.output.pindel.merged.vcf.gz \
--output-type v > ${tmp_sampleIndelsPindelGATKMerged}

#echo header into outputfile, and remove collumn headers
bcftools view -h ${tmp_sampleIndelsPindelGATKMerged} > ${tmp_sampleIndelsPindelGATKMerged}.tmp
sed -i '$ d' ${tmp_sampleIndelsPindelGATKMerged}.tmp

#create new header and replace header of output vcf using tabix
echo "#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	${externalSampleID}.GATK	${externalSampleID}.PINDEL" > ${intermediateDir}/${externalSampleID}.header.txt
bgzip -c ${tmp_sampleIndelsPindelGATKMerged} > ${tmp_sampleIndelsPindelGATKMerged}.gz
tabix -p vcf ${tmp_sampleIndelsPindelGATKMerged}.gz
tabix -r ${intermediateDir}/${externalSampleID}.header.txt ${tmp_sampleIndelsPindelGATKMerged}.gz >> ${tmp_sampleIndelsPindelGATKMerged}.reheadered.tmp.gz
gunzip ${tmp_sampleIndelsPindelGATKMerged}.reheadered.tmp.gz
cat ${tmp_sampleIndelsPindelGATKMerged}.reheadered.tmp >> ${tmp_sampleIndelsPindelGATKMerged}.tmp


mv ${tmp_sampleIndelsPindelGATKMerged}.tmp ${tmp_sampleIndelsPindelGATKMerged}
mv ${tmp_sampleIndelsPindelGATKMerged} ${sampleIndelsPindelGATKMerged}
