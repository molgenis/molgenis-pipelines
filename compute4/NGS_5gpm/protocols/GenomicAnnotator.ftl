
#MOLGENIS walltime=24:00:00 mem=10
#FOREACH externalSampleID

module load GATK/${gatkVersion}
module list

inputs "${indexfile}"
inputs "${baitsbed}"
inputs "${dbsnpSNPstxt}"
inputs "${snpsvcf}"
alloutputsexist "${snpsgenomicannotatedvcf}"

#####Annotate with dbSNP${dbsnpLatestVersionNumber} SNPs only#####
java -Xmx10g -jar ${genomeAnalysisTKjar} \
-T GenomicAnnotator \
-l info \
-R ${indexfile} \
-B:variant,vcf ${snpsvcf} \
-B:dbSNP${dbsnpLatestVersionNumber},AnnotatorInputTable ${dbsnpSNPstxt} \
-s dbSNP${dbsnpLatestVersionNumber}.AF,dbSNP${dbsnpLatestVersionNumber}.ASP,dbSNP${dbsnpLatestVersionNumber}.ASS,dbSNP${dbsnpLatestVersionNumber}.CDA,dbSNP${dbsnpLatestVersionNumber}.CFL,dbSNP${dbsnpLatestVersionNumber}.CLN,dbSNP${dbsnpLatestVersionNumber}.DSS,dbSNP${dbsnpLatestVersionNumber}.G5,\
dbSNP${dbsnpLatestVersionNumber}.G5A,dbSNP${dbsnpLatestVersionNumber}.GCF,dbSNP${dbsnpLatestVersionNumber}.GMAF,dbSNP${dbsnpLatestVersionNumber}.GNO,dbSNP${dbsnpLatestVersionNumber}.HD,dbSNP${dbsnpLatestVersionNumber}.INT,dbSNP${dbsnpLatestVersionNumber}.KGPROD,dbSNP${dbsnpLatestVersionNumber}.KGPilot1,dbSNP${dbsnpLatestVersionNumber}.KGPilot123,\
dbSNP${dbsnpLatestVersionNumber}.KGVAL,dbSNP${dbsnpLatestVersionNumber}.LSD,dbSNP${dbsnpLatestVersionNumber}.MTP,dbSNP${dbsnpLatestVersionNumber}.MUT,dbSNP${dbsnpLatestVersionNumber}.NOC,dbSNP${dbsnpLatestVersionNumber}.NOV,dbSNP${dbsnpLatestVersionNumber}.NS,dbSNP${dbsnpLatestVersionNumber}.NSF,dbSNP${dbsnpLatestVersionNumber}.NSM,dbSNP${dbsnpLatestVersionNumber}.OM,\
dbSNP${dbsnpLatestVersionNumber}.OTH,dbSNP${dbsnpLatestVersionNumber}.PH1,dbSNP${dbsnpLatestVersionNumber}.PH2,dbSNP${dbsnpLatestVersionNumber}.PH3,dbSNP${dbsnpLatestVersionNumber}.PM,dbSNP${dbsnpLatestVersionNumber}.PMC,dbSNP${dbsnpLatestVersionNumber}.R3,dbSNP${dbsnpLatestVersionNumber}.R5,dbSNP${dbsnpLatestVersionNumber}.REF,dbSNP${dbsnpLatestVersionNumber}.RSPOS,\
dbSNP${dbsnpLatestVersionNumber}.RV,dbSNP${dbsnpLatestVersionNumber}.S3D,dbSNP${dbsnpLatestVersionNumber}.SAO,dbSNP${dbsnpLatestVersionNumber}.SCS,dbSNP${dbsnpLatestVersionNumber}.SLO,dbSNP${dbsnpLatestVersionNumber}.SSR,dbSNP${dbsnpLatestVersionNumber}.SYN,dbSNP${dbsnpLatestVersionNumber}.TPA,dbSNP${dbsnpLatestVersionNumber}.U3,dbSNP${dbsnpLatestVersionNumber}.U5,dbSNP${dbsnpLatestVersionNumber}.VC,\
dbSNP${dbsnpLatestVersionNumber}.VLD,dbSNP${dbsnpLatestVersionNumber}.VP,dbSNP${dbsnpLatestVersionNumber}.WGT,dbSNP${dbsnpLatestVersionNumber}.WTD,dbSNP${dbsnpLatestVersionNumber}.dbSNPBuildID \
-o ${snpsgenomicannotatedvcf} \
-L ${baitsbed}