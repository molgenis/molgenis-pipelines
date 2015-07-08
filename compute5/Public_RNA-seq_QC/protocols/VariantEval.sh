#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

#string stage
#string checkStage
#string onekgGenomeFasta
#string gatkVersion
#string sampleName
#string internalId
#string toolDir
#string rawVCF
#string uniqueID
#string jdkVersion
#string variantEvalDir
#string evalGrp


getFile ${rawVCF}

#Load modules
${stage} GATK/${gatkVersion}

#check modules
${checkStage}

mkdir -p ${variantEvalDir}

echo "## "$(date)" Start $0"

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
   -T VariantEval \
   -R ${onekgGenomeFasta} \
   -o ${evalGrp} \
   --eval ${rawVCF} \

then
  echo "returncode: $?";
  putFile ${evalGrp}
  echo "succes moving file";

else
  echo "returncode: $?";
  echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
