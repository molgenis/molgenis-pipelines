#
# =====================================================
# $Id$
# $URL: http://www.molgenis.org/svn/molgenis_apps/trunk/modules/compute/protocols/Realign.ftl $
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy: pneerincx $
# =====================================================
#

#MOLGENIS walltime=35:59:00 mem=4 cores=1

inputs "${dedupbam}" 
inputs "${indexfile}" 
inputs "${dbsnprod}"
inputs "${pilot1KgVcf}"
inputs "${realignTargets}"
alloutputsexist "${realignedbam}"

java -Djava.io.tmpdir=${tempdir} -Xmx4g -jar \
${genomeAnalysisTKjar} \
-l INFO \
-T VariantRecalibrator \
-R ${indexfile} \
   -input NA12878.HiSeq.WGS.bwa.cleaned.raw.subset.b37.vcf \
   -resource:hapmap,known=false,training=true,truth=true,prior=15.0 hapmap_3.3.b37.sites.vcf \
   -resource:omni,known=false,training=true,truth=false,prior=12.0 1000G_omni2.5.b37.sites.vcf \
   -resource:dbsnp,known=true,training=false,truth=false,prior=8.0 dbsnp_132.b37.vcf \
-B:concordantSet,VCF,known=true,training=true,truth=true,prior=10.0 path/to/concordantSet.vcf 
   -an QD -an HaplotypeScore -an MQRankSum -an ReadPosRankSum -an MQ \
   -recalFile path/to/output.recal \
   -tranchesFile path/to/output.tranches \
   -rscriptFile path/to/output.plots.R
