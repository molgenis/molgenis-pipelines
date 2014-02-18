#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=45:59:00 mem=4 cores=1

module load GATK/1.0.5069
module list

inputs "${indexfile}" 
inputs "${matefixedbam}"
inputs "${matefixedcovariatecsv}"
inputs "${fivegpm200flankbed}"
alloutputsexist "${recalbam}"

java -jar -Xmx4g \
$GATK_HOME/GenomeAnalysisTK.jar \
-l INFO \
-T TableRecalibration \
-U ALLOW_UNINDEXED_BAM \
-R ${indexfile} \
-I ${matefixedbam} \
-L ${fivegpm200flankbed} \
--recal_file ${matefixedcovariatecsv} \
--out ${recalbam}