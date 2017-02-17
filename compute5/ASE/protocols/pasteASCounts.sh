#MOLGENIS walltime=05:59:00 mem=8gb nodes=1 ppn=2

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string selectVariantsBiallelicSNPsVcf
#string CHR
#string ASVCF
#string binDir
#string countsTable
#list ASCountFile


#string bedtoolsVersion
#string samtoolsVersion
#string tabixVersion
#string GSLVersion
#string RASQUALDIR
#string ASCountsDir

echo "## "$(date)" Start $0"

${stage} BEDTools/${bedtoolsVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} tabix/${tabixVersion}
${stage} GSL/${GSLVersion}
${checkStage}

mkdir -p ${binDir}

echo "Merging ASreads"
export RASQUALDIR # rasqual must be declared and exported. Other scripts are in rasqualdir... what happens here

# pasteFiles does not give an error when vcf and counts table have different number of SNPs, and it doesn't 
# use chr/pos info so if the number of lines is not the same it should exit
numberOfVcfs=$(zcat ${selectVariantsBiallelicSNPsVcf} | grep -v '^#' | wc -l
numberOfCounts=$(wc -l ${countsTable} | awk '{print $1}' )

if [ ${numerOfVcfs} -ne ${numberOfCounts} ];
then
  echo "ERROR"
  echo "Number of lines in ${selectVariantsBiallelicSNPsVcf}: ${numberOfVcfs}"
  echo "Number of lines in ${countsTable}: ${numberOfCounts}"
  echo "Should be the same..."
  exit 1;
fi

##########################################################################AFter this check mpileup for the 3% anomaly for test snps 
# count AS reads
$RASQUALDIR/src/ASVCF/pasteFiles ${selectVariantsBiallelicSNPsVcf} ${countsTable} | \
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
