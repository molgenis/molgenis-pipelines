
module load GATK/${gatkVersion}
module list

inputs "${matefixedbam}"
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${baitsbed}"
alloutputsexist "${matefixedcovariatecsv}"

java -jar -Xmx4g \
${genomeAnalysisTKjar} -l INFO \
-T CountCovariates \
-U ALLOW_UNINDEXED_BAM \
-R ${indexfile} \
--DBSNP ${dbsnprod} \
-I ${matefixedbam} \
-L ${baitsbed} \
-cov ReadGroupcovariate \
-cov QualityScoreCovariate \
-cov CycleCovariate \
-cov DinucCovariate \
-recalFile ${matefixedcovariatecsv}