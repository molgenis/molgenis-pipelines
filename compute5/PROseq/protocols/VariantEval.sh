#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database 
#string sampleName
#string project
###
#string stage
#string checkStage
#string onekgGenomeFasta
#string gatkVersion
#string toolDir
#string haplotyperGvcf
#string uniqueID
#string jdkVersion
#string variantEvalDir
#string evalGrp

#Load modules
${stage} GATK/${gatkVersion}

#check modules
${checkStage}

mkdir -p ${variantEvalDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${project}-${sampleName}"

if java -Xmx8g -XX:ParallelGCThreads=4 -jar ${toolDir}GATK/${gatkVersion}/GenomeAnalysisTK.jar \
   -T VariantEval \
   -R ${onekgGenomeFasta} \
   -o ${evalGrp} \
   --eval ${haplotyperGvcf} \

then
  echo "returncode: $?";
cd ${variantEvalDir}
md5sum $(basename ${evalGrp}) > $(basename ${evalGrp}).md5
  echo "succes moving file";
cd -
else
  echo "returncode: $?";
  echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
