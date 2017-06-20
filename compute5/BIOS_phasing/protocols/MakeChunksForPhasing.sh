#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=4

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage

#string WORKDIR
#string bglchunkDir
#string genotypedChrVcfBeagleGenotypeProbabilitiesFiltered
#string makeBGLCHUNKSVersion
#string bglchunkOutfile

${stage} makeBGLCHUNKS/${makeBGLCHUNKSVersion}
${checkStage}

mkdir -p ${bglchunkDir}

makeBGLCHUNKS --vcf ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered}  --window 700 --overlap 200 --output ${bglchunkOutfile}

endPosVCF=$(zcat ${genotypedChrVcfBeagleGenotypeProbabilitiesFiltered} |  tail -n 1 | awk '{ print $2 }')
endPosChunks=$(tail -n 1 ${bglchunkOutfile} | awk '{print $3}')

echo "End pos VCF: $endPosVCF"
echo "End pos chunk: $endPosChunks"

if [ "$endPosChunks" -le "$endPosVCF" ];
then
  echo "end pos chunks not larger or equal to end pos VCF, should always be larger"
  startLastChunk=$(tail -n 1 ${bglchunkOutfile} | awk '{print $2}')
  chr=$(tail -n 1 ${bglchunkOutfile} | awk '{print $1}')
  echo "add a bit to endpos because otherwise last pos will still not be read"
  let $endPosVCF=$endPosVCF+10000
  echo  "Add    $chr   $startLastChunk    $endPosVCF    to chunk file"
  echo -e "$chr\t$startLastChunk\t$endPosVCF" >> ${bglchunkOutfile}
fi

echo "returncode: $?";

echo "## "$(date)" ##  $0 Done "
