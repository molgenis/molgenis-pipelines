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
#string AseOutput
#string ASReadsDir
#string couplingFile
#list ASReads
#string AseVersion
echo "## "$(date)" Start $0"


#Load gatk module
${stage} ASE/${AseVersion}
${checkStage}

mkdir -p ${AseDir}

printf '%s\n' "${ASReads[@]}" > ${ASFiles}

if java -jar ${EBROOTASE}/cellTypeSpecificAlleleSpecificExpression.jar \
--action 2 \
--output ${AseOutput} \
--as_locations ${ASFiles} \
--minimum_hets 1 \
--minimum_reads 10

then
 echo "returncode: $?";
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "I
