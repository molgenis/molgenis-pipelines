#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string rasqualFeatureChrOutput
#string rasqualFeatureChrPermutationOutput
#list rasqualFeatureChunkOutput,rasqualFeatureChunkPermutationOutput



echo "## "$(date)" Start $0"


getFile ${onekgGenomeFasta}

${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${ASEReadCountsDir}


#For all chromosome feature chunks
for OCHUNK in "${rasqualFeatureChunkOutput[@]}"
do
#Check if files all exists, if so cat them into one chromosome file
	if [ -f "$OCHUNK" ];
	then
	   echo -e -n "$OCHUNK exists\n"
	else
	   echo -e -n "$OCHUNK does not exist, ending now\n"
	   exit 1;
	fi
done
for PCHUNK in "${rasqualFeatureChunkPermutationOutput[@]}"
do
#Check if files all exists, if so cat them into one chromosome file
	if [ -f "$PCHUNK" ];
	then
	   echo -e -n "$PCHUNK exists\n"
	else
	   echo -e -n "$PCHUNK does not exist, ending now\n"
	   exit 1;
	fi
done


#Cat all feature chunks into one merged chromosome output file
cat ${rasqualFeatureChunkOutput[@] > ${rasqualFeatureChrOutput}
cat ${rasqualFeatureChunkPermutationOutput[@] > ${rasqualFeatureChrPermutationOutput}


#Putfile the results
if [ -f "${rasqualFeatureChrOutput}" ];
then
 echo "returncode: $?"; 
 putFile ${rasqualFeatureChrOutput}
 putFile ${rasqualFeatureChrPermutationOutput}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi

echo "## "$(date)" ##  $0 Done "

