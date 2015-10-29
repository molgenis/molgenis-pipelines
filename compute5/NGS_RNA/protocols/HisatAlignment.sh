#MOLGENIS nodes=1 ppn=8 mem=8gb walltime=03:00:00

#string project
#string stage
#string checkStage
#string hisatIndex
#string leftbarcodefqgz
#string rightbarcodefqgz
#string intermediateDir
#string alignedSam
#string alignedFilteredBam
#string sortedBam
#string sortedBai
#string hisatVersion
#string externalSampleID
#string samtoolsVersion
#string picardVersion
#string sequencer
#string library
#string flowcell
#string run
#string barcode
#string lane
#string tempDir

if [ ${#rightbarcodefqgz} -eq 0 ]; then
	input="-U ${leftbarcodefqgz}"
	echo "Single end alignment of ${leftbarcodefqgz}"
else
	input="-1 ${leftbarcodefqgz} -2 ${rightbarcodefqgz}"
	echo "Paired end alignment of ${leftbarcodefqgz} and ${rightbarcodefqgz}"
fi

#Load modules
${stage} ${hisatVersion}
${stage} ${samtoolsVersion}
${stage} ${picardVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"

if hisat -x ${hisatIndex} \
	${input} \
	-p 8 \
	--rg-id ${externalSampleID} \
	--rg PL:illumina \
	--rg PU:${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	--rg LB:${sequencer}_${flowcell}_${run}_${lane}_${barcode} \
	--rg SM:${externalSampleID} \
	-S ${alignedSam}
then
	echo "returncode: $?";
	echo "succes moving files";
else
	echo "returncode: $?";
	echo "fail";
fi

if sed '/NH:i:[^1]/d' ${alignedSam} | samtools view -h -b - > ${alignedFilteredBam}
then
	echo "Reads with flag NH:i:[2+] where filtered out (only leaving 'unique' mapping reads)."
	rm ${alignedSam}
	echo "returncode: $?";
	echo "succes moving files";
else
	echo "returncode: $?";
	echo "fail";
fi

echo "## "$(date)" Start $0"

if java -Xmx6g -XX:ParallelGCThreads=4 -jar ${EBROOTPICARD}/SortSam.jar \
	INPUT=${alignedFilteredBam} \
	OUTPUT=${sortedBam} \
 	SO=coordinate \
	CREATE_INDEX=true \
	TMP_DIR=${tempDir}

then
	echo "returncode: $?";
	echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "
