#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=24:00:00 mem=10
#FOREACH externalSampleID

inputs "${indexfile}"
inputs "${baitsbed}"
inputs "${dbsnpSNPstxt}"
inputs "${snpsvcf}"
alloutputsexist "${snpsgenomicannotatedvcf}"

#####Annotate with dbSNP135 SNPs only#####
java -Xmx10g -jar ${genomeAnalysisTKjar} \
-T GenomicAnnotator \
-l info \
-R ${indexfile} \
-B:variant,vcf ${snpsvcf} \
-B:dbSNP135,AnnotatorInputTable ${dbsnpSNPstxt} \
-s dbSNP135.AF,dbSNP135.ASP,dbSNP135.ASS,dbSNP135.CDA,dbSNP135.CFL,dbSNP135.CLN,dbSNP135.DSS,dbSNP135.G5,\
dbSNP135.G5A,dbSNP135.GCF,dbSNP135.GMAF,dbSNP135.GNO,dbSNP135.HD,dbSNP135.INT,dbSNP135.KGPROD,dbSNP135.KGPilot1,dbSNP135.KGPilot123,\
dbSNP135.KGVAL,dbSNP135.LSD,dbSNP135.MTP,dbSNP135.MUT,dbSNP135.NOC,dbSNP135.NOV,dbSNP135.NS,dbSNP135.NSF,dbSNP135.NSM,dbSNP135.OM,\
dbSNP135.OTH,dbSNP135.PH1,dbSNP135.PH2,dbSNP135.PH3,dbSNP135.PM,dbSNP135.PMC,dbSNP135.R3,dbSNP135.R5,dbSNP135.REF,dbSNP135.RSPOS,\
dbSNP135.RV,dbSNP135.S3D,dbSNP135.SAO,dbSNP135.SCS,dbSNP135.SLO,dbSNP135.SSR,dbSNP135.SYN,dbSNP135.TPA,dbSNP135.U3,dbSNP135.U5,dbSNP135.VC,\
dbSNP135.VLD,dbSNP135.VP,dbSNP135.WGT,dbSNP135.WTD,dbSNP135.dbSNPBuildID \
-o ${snpsgenomicannotatedvcf} \
-L ${baitsbed}