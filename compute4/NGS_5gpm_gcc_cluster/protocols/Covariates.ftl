#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

module load GATK/1.0.5069
module list

inputs "${matefixedbam}"
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${fivegpm200flankbed}"
alloutputsexist "${matefixedcovariatecsv}"

java -jar -Xmx4g \
$GATK_HOME/GenomeAnalysisTK.jar -l INFO \
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