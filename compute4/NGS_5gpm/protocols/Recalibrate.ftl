
#MOLGENIS walltime=45:59:00 mem=4 cores=1

module load GATK/${gatkVersion}
module list

inputs "${indexfile}" 
inputs "${matefixedbam}"
inputs "${matefixedcovariatecsv}"
inputs "${baitsbed}"
alloutputsexist "${recalbam}"

java -jar -Xmx4g \
${genomeAnalysisTKjar} \
-l INFO \
-T TableRecalibration \
-U ALLOW_UNINDEXED_BAM \
-R ${indexfile} \
-I ${matefixedbam} \
-L ${baitsbed} \
--recal_file ${matefixedcovariatecsv} \
--out ${recalbam}