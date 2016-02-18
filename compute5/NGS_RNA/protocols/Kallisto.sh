#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=01:00:00

#Parameter mapping
#string seqType
#string lane
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string kallistoVersion
#string externalSampleID
#string kallistoIndex
#string fragmentLength
#string project

#Load module
module load ${kallistoVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

echo "## "$(date)" Start $0"
echo "ID (project-internalSampleID-lane): ${project}-${externalSampleID}-L${lane}"

uniqueID="${project}-${externalSampleID}-L${lane}"

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then

  mkdir -p ${tmpIntermediateDir}/${uniqueID}
  echo "Paired end kallisto of ${peEnd1BarcodeFqGz} and ${peEnd2BarcodeFqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${tmpIntermediateDir}/${uniqueID} \
    ${peEnd1BarcodeFqGz} ${peEnd2BarcodeFqGz}
  then
    echo "returncode: $?"; putFile ${tmpIntermediateDir}/${uniqueID}/abundance.tsv

    cd ${tmpIntermediateDir}/${uniqueID} 

    md5sum abundance.h5 > abundance.h5.md5
    md5sum run_info.json > run_info.json.md5
    md5sum abundance.tsv > abundance.tsv.md5
    cd -

    mv -f ${tmpIntermediateDir}/${uniqueID} ${intermediateDir} 
    echo "succes moving files";

  else

    echo "returncode: $?";
    echo "fail";

  fi

else

  mkdir -p ${tmpIntermediateDir}/${uniqueID}_${fragmentLength}
  echo "Single end kallisto of ${srBarcodeFqGz}"
  if kallisto quant \
    -i ${kallistoIndex} \
    -o ${tmpIntermediateDir}/${uniqueID}_${fragmentLength} \
    --single \
    -l ${fragmentLength} \
    ${srBarcodeFqGz}
  then
    echo "returncode: $?"; 

    cd ${tmpIntermediateDir}/${uniqueID}_${fragmentLength}

    md5sum abundance.h5 > abundance.h5.md5
    md5sum run_info.json > run_info.json.md5
    md5sum abundance.tsv > abundance.tsv.md5
    cd -

    mv -f ${tmpIntermediateDir}/${uniqueID}_${fragmentLength}/ ${intermediateDir}
    echo "succes moving files";

  else

    echo "returncode: $?";
    echo "fail";

  fi

	
fi

echo "## "$(date)" ##  $0 Done "
