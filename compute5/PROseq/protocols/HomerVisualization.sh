#MOLGENIS walltime=23:59:00 mem=12gb ppn=8

### variables to help adding to database (have to use weave)
#string sampleName
#string project
###
#string stage
#string checkStage
#string homerTagDir
#string toolDir
#string homerLocation
#string weblogoVersion
#string samtoolsVersion
#string bedgraphBigwigLocation

echo "## "$(date)" Start $0"
echo "ID (project-sampleName): ${project}-${sampleName}"
# bad! But Homer is near impossible to install with easybuild so can't use module load
PATH=$PATH:${homerLocation}
PATH=$PATH:${bedgraphBigwigLocation}


#Load gatk module
${stage} SAMtools/${samtoolsVersion}
${stage} Weblogo/${weblogoVersion}
${checkStage}

if makeUCSCfile ${homerTagDir} -o auto -strand separate
then
  cd ${homerTagDir}
  gunzip ${homerTagDir}).ucsc.bedGraph.gz
  cd -
  perl -ne 'if(/- strand/){$a=1} ; $a==1 ? print STDERR : print STDOUT;' ${homerTagDir}/$(basename ${homerTagDir}).ucsc.bedGraph >${homerTagDir}/${sampleName}_positive_strand.bedgraph 2>${homerTagDir}/${sampleName}_negative_strand.bedgraph;
  awk '{print >out}; //{out="h"}' out=

 echo "returncode: $?"; 
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
