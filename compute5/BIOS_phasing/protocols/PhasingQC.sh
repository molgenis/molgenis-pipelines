#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string sampleName
###
#string stage
#string checkStage
#string shapeitPhasedOutputPrefix
#string phaserOutPrefix
#string couplingFile
#string phasingQcDir
#string phasingQCOutput
#string checkVCF

#Load modules
${stage} Python/${PythonVersion}


#check modules
${checkStage}

mkdir -p ${phasingQcDir}

echo "## "$(date)" Start $0c

if
  python ../scripts/phasingQC_0.02.py \
    -i ${phaserOutPrefix}.recode.vcf \
    -I ${checkVCF} \
    -o ${phasingQCOutput} \
    -c ${couplingFile}

then
RScript ../scripts/../qcPhasingPlots.R --arg1=${phasingQCOutput} --arg2=${phasingQcDir}
  echo "returncode: $?";
  echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
