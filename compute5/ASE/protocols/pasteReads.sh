#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=2### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string exonlist
#string genelist
#string yfiletxtExon
#string yfiletxtGene
#string featureType
#string binDir
#string bedtoolsVersion
#string samtoolsVersion
#string tabixVersion
#string sampleNum
#list readCountFileExon,readCountFileGene
${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}
mkdir -p ${binDir}
#Start######################
echo "## "$(date)" Start $0"
################################
echo Generating Y file per exon ID
################################
# Generate Y file
cut -f5,6 ${exonlist} |  awk '{print $1"."$2}' | \
	paste -d "\t" - "${readCountFileExon[@]}" | cut -f1-$((${sampleNum}+1)) > ${yfiletxtExon}
##############################
echo Generating Y file per transcript ID
##############################
cut -f5 ${genelist} | \
        paste -d "\t" - "${readCountFileGene[@]}" | cut -f1-$((${sampleNum}+1)) > ${yfiletxtGene}
#FINISH#########################
echo "## "$(date)" ##  $0 Done "
################################
