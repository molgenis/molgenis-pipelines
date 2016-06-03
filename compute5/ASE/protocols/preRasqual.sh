#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string yfiletxtExon
#string yfiletxtGene
#string featureType
#string binDir
#string RVersion
#string RasqualizeScript
#string exonGC
#string transcriptGC
${stage} R/${RVersion}

mkdir -p ${binDir}
#Start######################
echo "## "$(date)" Start $0"
################################
echo Generating bins for exon files
################################
Rscript ${RasqualizeScript} ${yfiletxtExon} ${exonGC}
##############################
echo Generating Y bins for transcript files
##############################
if [ ${featureType} == exon ]; then exit; fi
Rscript ${RasqualizeScript} ${yfiletxtGene} ${transcriptGC}
#FINISH#########################
echo "## "$(date)" ##  $0 Done "
################################
