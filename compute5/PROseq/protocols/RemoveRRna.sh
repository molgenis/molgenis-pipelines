#MOLGENIS nodes=1 ppn=8 mem=1gb walltime=10:00:00

#string stage
#string checkStage
#string rRNAdustVersion
#string WORKDIR
#string projectDir
#string rRNAfilteredDir
#string reads1FqGz
#string reads2FqGz
#string sampleName


${stage} rRNAdust/${rRNAdustVersion}
${checkStage}

set -e

echo "## "$(date)" ##  $0 Started "


if rRNAdust ${rRNArefSeq}  ${reads1FqGz} -e 2 > ${rRNAfilteredDir}/${reads1FqGz##*/}
 if [ ${#reads2FqGz} -eq 1 ]; then
  rRNAdust ${rRNArefSeq}  ${reads2FqGz} -e 2 > ${rRNAfilteredDir}/${reads2FqGz##*/}
 fi
then
 echo "returncode: $?";
 putFile ${rRNAfilteredDir}/${reads1FqGz##*/}
 putFile ${rRNAfilteredDir}/${reads2FqGz##*/}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
 fi
fi

echo "## "$(date)" ##  $0 Done "