#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=10:00:00

#string stage
#string checkStage
#string fastqcVersion
#string WORKDIR
#string projectDir
#string fastqcDir
#string fastqcZipExt
#string pairedEndfastqcZip1
#string pairedEndfastqcZip2
#string reads1FqGz
#string reads2FqGz
#string sampleName

echo -e "test ${reads1FqGz} ${reads2FqGz} 1: $(basename ${reads1FqGz} .gz)${fastqcZipExt} \n2: $(basename ${reads2FqGz} .gz)${fastqcZipExt} "

${stage} FastQC/${fastqcVersion}
${checkStage}

set -e

echo "## "$(date)" ##  $0 Started "

if [ ${#reads2FqGz} -eq 0 ]; then
	
	echo "## "$(date)" Started single end fastqc"
	alloutputsexist \
	 ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt} \
	 ${singleEndfastqcZip}

	getFile ${reads1FqGz}
	
	mkdir -p ${fastqcDir}
	cd ${fastqcDir}
	
	##################################################################
	echo
	echo "## "$(date)" reads1FqGz"
	if fastqc --noextract ${reads1FqGz} --outdir ${fastqcDir}
	  echo
	  cp -v ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt} ${singleEndfastqcZip}

	  ##################################################################
	
	  cd $OLDPWD
    then
      echo "returncode: $?";
      putFile ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt}
      putFile ${singleEndfastqcZip}
      echo "succes moving files";
    else
      echo "returncode: $?";
      echo "fail";
    fi


else
	echo "## "$(date)" Started paired end fastqc"
	
	alloutputsexist \
	 ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt} \
	 ${fastqcDir}/$(basename ${reads2FqGz} .gz)${fastqcZipExt} \
	 ${pairedEndfastqcZip1} \
	 ${pairedEndfastqcZip2}

	getFile ${reads1FqGz}
	getFile ${reads2FqGz}
	
	mkdir -p ${fastqcDir}
	cd ${fastqcDir}
	
	##################################################################
	echo
	echo "## "$(date)" reads1FqGz"
	if fastqc --noextract ${reads1FqGz} --outdir ${fastqcDir}
	
	  cp -v ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt} ${pairedEndfastqcZip1}
	  echo
	  echo "## "$(date)" reads2FqGz"
	  fastqc --noextract ${reads2FqGz} --outdir ${fastqcDir}
	  echo
	  cp -v ${fastqcDir}/$(basename ${reads2FqGz} .gz)${fastqcZipExt} ${pairedEndfastqcZip2}

	  ##################################################################
	  cd $OLDPWD

    then
      echo "returncode: $?";
      putFile ${fastqcDir}/$(basename ${reads1FqGz} .gz)${fastqcZipExt}
      putFile ${fastqcDir}/$(basename ${reads2FqGz} .gz)${fastqcZipExt}
      putFile ${pairedEndfastqcZip1}
      putFile ${pairedEndfastqcZip2}

      echo "succes moving files";
    else
      echo "returncode: $?";
      echo "fail";
    fi
fi


echo "## "$(date)" ##  $0 Done "
