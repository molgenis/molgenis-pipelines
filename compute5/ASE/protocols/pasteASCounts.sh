#MOLGENIS walltime=05:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string VCF
#string CHR
#string ASVCF
#string binDir
#string countsTable
#list ASCountFile


#string bedtoolsVersion
#string samtoolsVersion
#string tabixVersion
#string RASQUALDIR
#string ASCountsDir

echo "## "$(date)" Start $0"

${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}
${checkStage}

mkdir -p ${binDir}

echo "Merging ASreads"
export RASQUALDIR # rasqual must be declared and exported. Other scripts are in rasqualdir... what happens here
##########################################################################AFter this check mpileup for the 3% anomaly for test snps 
# count AS reads
$RASQUALDIR/src/ASVCF/pasteFiles ${VCF} ${countsTable} | \
bgzip > ${ASVCF}
tabix -f -p vcf ${ASVCF}

echo "Done merging ASreads"


#Putfile the results
if [ -f "${ASVCF}" ];
then
 echo "returncode: $?"; 
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi


echo "## "$(date)" $0 Done"
