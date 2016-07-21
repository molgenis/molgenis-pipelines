#MOLGENIS walltime=23:59:00 mem=8gb ppn=1

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string projectDir

#string AseDir
#string ASFilesPrefix
#string AseOutput
#string ASReadsDir
#string couplingFile
#string CHR
#list ASReadsPrefix
#string AseVersion
echo "## "$(date)" Start $0"


#Load gatk module
${stage} CS-ASE/${AseVersion}
${checkStage}

mkdir -p ${AseDir}

ASReadsUniq=($(printf "%s_chr${CHR}.txt\n" "${ASReadsPrefix[@]}" | sort -u))

printf '%s\n' "${ASReadsUniq[@]}"  > ${ASFilesPrefix}_chr${CHR}.txt
if java -jar ${EBROOTCSMINASE}/cellTypeSpecificAlleleSpecificExpression-${AseVersion%-Java*}-jar-with-dependencies.jar \
--action 2 \
--output ${AseOutput} \
--as_locations ${ASFilesPrefix}_chr${CHR}.txt \
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
