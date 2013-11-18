#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

inputs "${matefixedbam}"
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${fivegpm200flankbed}"
alloutputsexist "${matefixedcovariatecsv}"

java -jar -Xmx4g \
${genomeAnalysisTKjar} -l INFO \
-T CountCovariates \
-U ALLOW_UNINDEXED_BAM \
-R ${indexfile} \
--DBSNP ${dbsnprod} \
-I ${matefixedbam} \
-L ${fivegpm200flankbed} \
-cov ReadGroupcovariate \
-cov QualityScoreCovariate \
-cov CycleCovariate \
-cov DinucCovariate \
-recalFile ${matefixedcovariatecsv}