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
#list sampleName
#list readCountFileExon,readCountFileGene



${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}
${checkStage}

mkdir -p ${binDir}

echo "## "$(date)" Start $0"

#Extract total number of samples from samplesheet.csv
NUMSAMPLES=${#sampleName[*]}
echo "Number of samples in samplesheet.csv: $NUMSAMPLES"


echo Generating Y file per exon ID

# Generate Y file
cut -f2,5 ${exonlist} |  awk '{print $1"."$2}' | \
	paste -d "\t" - "${readCountFileExon[@]}" | cut -f1-$(($NUMSAMPLES+1)) > ${yfiletxtExon}

echo Generating Y file per transcript ID

cut -f5 ${genelist} | LC_ALL=C sort -t $'\t' -k1,1 | \
        paste -d "\t" - "${readCountFileGene[@]}" | cut -f1-$(($NUMSAMPLES+1)) > ${yfiletxtGene}

echo "## "$(date)" ##  $0 Done "

