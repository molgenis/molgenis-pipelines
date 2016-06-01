#MOLGENIS nodes=1 ppn=8 mem=10gb walltime=23:59:00

#string project
#string stage
#string checkStage
#string sampleMergedDedupBam
#string sampleMergedDedupBai
#string samtoolsVersion
#string gatkVersion
#string intermediateDir
#string	externalSampleID
#string splitAndTrimBam
#string splitAndTrimBai
#string tmpDataDir
#string indexFile
#string tmpTmpDataDir
#string project
#string groupname
#string tmpName

makeTmpDir ${splitAndTrimBam} 
tmpsplitAndTrimBam=${MC_tmpFile}

makeTmpDir ${splitAndTrimBai}
tmpsplitAndTrimBai=${MC_tmpFile}

#Load Modules
${stage} ${gatkVersion}
${stage} ${samtoolsVersion}

#check modules
${checkStage}

echo "## "$(date)" Start $0"

echo
echo
echo "Running split and trim:"

  java -Xmx9g -XX:ParallelGCThreads=8 -Djava.io.tmpdir=${tmpTmpDataDir} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
  -T SplitNCigarReads \
  -R ${indexFile} \
  -I ${sampleMergedDedupBam} \
  -o ${tmpsplitAndTrimBam} \
  -rf ReassignOneMappingQuality \
  -RMQF 255 \
  -RMQT 60 \
  -U ALLOW_N_CIGAR_READS


  mv ${tmpsplitAndTrimBam} ${splitAndTrimBam}
  mv ${tmpsplitAndTrimBai} ${splitAndTrimBai}

  # Create md5sum for zip file
	
  RUNDIR=${PWD}
  cd ${intermediateDir}
  md5sum ${splitAndTrimBam} > ${splitAndTrimBam}.md5
  md5sum ${splitAndTrimBai} > ${splitAndTrimBai}.md5
  echo "returncode: $?";
  echo "succes moving files";
  cd ${RUNDIR}

  echo "## "$(date)" ##  $0 Done "

