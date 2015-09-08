#MOLGENIS nodes=1 ppn=8 mem=6gb walltime=06:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string hisatVersion
#string samtoolsVersion
#string WORKDIR
#string projectDir
#string rRNAfilteredDir
#string rRNArefSeq
#string singleEndRC
#string singleEndRRna
#string picardVersion
#string toolDir

${stage} hisat/${hisatVersion}
${stage} SAMtools/${samtoolsVersion}
${stage} picard/${picardVersion}
${checkStage}

echo "## "$(date)" ##  $0 Started "
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"
echo "ONLY WORKS FOR SINGLE-END"
mkdir -p ${rRNAfilteredDir}
#if [ ${#reads2FqGz} -eq 0 ]; then
input="-U ${singleEndRC}"
echo "Single end alignment of ${singleEndRC}"
#else
#   input="-1 ${reads1FqGz} -2 ${reads2FqGz}"
#   echo "Paired end alignment of ${reads1FqGz} and ${reads2FqGz}"
#fi
echo "hisat -x ${rRNArefSeq} \
  ${input}\
  -p 8 \
  -S ${rRNAfilteredDir}/${sampleName}_${internalId}_rRNA.sam"
if hisat -x ${rRNArefSeq} \
  ${input}\
  -p 8 \
  -S ${rRNAfilteredDir}/${sampleName}_${internalId}_rRNA.sam
then
    samtools view -f 4 ${rRNAfilteredDir}/${sampleName}_${internalId}_rRNA.sam > ${rRNAfilteredDir}/not_mapped_against_rRNA_${sampleName}_${internalId}.sam
    #java -Xmx6g -XX:ParallelGCThreads=8 -jar ${toolDir}picard/${picardVersion}/SamToFastq.jar \
    #    INPUT=${rRNAfilteredDir}/not_mapped_against_rRNA_${sampleName}_${internalId}.sam \
    #    FASTQ=${singleEndRRna} \
    #    MAX_RECORDS_IN_RAM=4000000 \
    #    TMP_DIR=${rRNAfilteredDir}
    cat ${rRNAfilteredDir}/not_mapped_against_rRNA_${sampleName}_${internalId}.sam | grep -v ^@ | awk '{print "@"$1"\n"$10"\n+\n"$11}' > ${singleEndRRna}

    echo "returncode: $?";
    echo "succes moving files";
else
    echo "returncode: $?";
    echo "fail";
fi

echo "## "$(date)" ##  $0 Done "