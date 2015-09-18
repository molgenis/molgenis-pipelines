#MOLGENIS walltime=23:59:00 mem=8gb ppn=1

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir
#string dbsnpVcf
#string dbsnpVcfIdx

#string tabixVersion
#string samtoolsVersion
#string haplotyperDir
#string AseDir
#string ASFiles
#list ASReads
echo "## "$(date)" Start $0"


#Load gatk module
${checkStage}

mkdir -p ${ASReadsDir}

($(printf '%s\n' "${ASReads[@]}")) >

if java -jar /groups/umcg-wijmenga/tmp04/umcg-ndeklein/scripts/cellTypeSpecificAlleleSpecificExpression-1.0.3_niekRequest-jar-with-dependencies.jar \
--action ASEperSNP \
--output ${AseOutput}
--as_locations ${ASFiles} \
--minimum_hets 1 \
--minimum_reads 10

then

 echo "returncode: $?";
 sort -n -k 6,6 ${AseOutput}_BetaBinomialResults.txt > ${AseOutput}_BetaBinomialResults_sorted.txt
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
