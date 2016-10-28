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
#string CHR
#string kfiletxtExon
#string kfilebinExon
#string yfilebinExon
#string xfiletxtExon
#string kfiletxtGene
#string kfilebinGene
#string yfilebinGene
#string xfiletxtGene


${stage} R/${RVersion}
${checkStage}

mkdir -p ${binDir}

echo "## "$(date)" Start $0"


echo Generating bins for exon files

Rscript ${RasqualizeScript} ${yfiletxtExon} ${exonGC} ${kfiletxtExon} ${kfilebinExon} ${yfilebinExon} ${xfiletxtExon}

echo Generating Y bins for transcript files

if [ ${featureType} == exon ]; then exit; fi
Rscript ${RasqualizeScript} ${yfiletxtGene} ${transcriptGC} ${kfiletxtGene} ${kfilebinGene} ${yfilebinGene} ${xfiletxtGene}


echo "## "$(date)" ##  $0 Done "

