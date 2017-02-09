#MOLGENIS nodes=1 ppn=2 mem=6gb walltime=01:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string countsTableDir
#string ASEReadCountsSampleChrOutput
#string sampleCountsTable
#string selectVariantsBiallelicSNPsVcf


#Function to check if a value is present in array/list
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}


echo "## "$(date)" Start $0"



#Commented progressbar out because the module is working on calculon, but broken on the nodes
##${stage} Term-ProgressBar/2.17-foss-2015b
${checkStage}

mkdir -p ${countsTableDir}

perl /apps/data/UMCG/scripts/convertASEReadCounts2CountsTable.pl \
  --VCF ${selectVariantsBiallelicSNPsVcf} \
  --ASEReadCounts ${ASEReadCountsSampleChrOutput} \
  --outputFile ${sampleCountsTable}
#Putfile the results
if [ -f "${sampleCountsTable}" ];
then
 echo "returncode: $?"; 
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 exit 1;
fi


echo "## "$(date)" ##  $0 Done "
