#MOLGENIS walltime=23:59:00 mem=8gb ppn=1

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string AseDir
#string ASFiles
#string AseOutput
#string ASReadsDir
#string couplingFile
#list ASReads
#string AseVersion
echo "## "$(date)" Start $0"


#Load gatk module
${stage} CS-ASE/${AseVersion}
${checkStage}

mkdir -p ${AseDir}

ASReadsUniq=($(printf "%s\n" "${ASReads[@]}" | sort -u))

printf '%s\n' "${ASReadsUniq[@]}"  > ${ASFiles}
if java -jar ${EBROOTCSMINASE}/cellTypeSpecificAlleleSpecificExpression-${AseVersion%-Java*}-jar-with-dependencies.jar \
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
