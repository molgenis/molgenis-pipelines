#MOLGENIS walltime=23:59:00 mem=6gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string realignedBam
#string realignedBamIdx
#string beforeRecalTable
#string BQSRBam
#string BQSRBamIdx
#string BQSRBamMd5
#string externalSampleID
#string tmpDataDir
#string project

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "gatkVersion: ${gatkVersion}"
echo "gatkJar: ${gatkJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "realignedBam: ${realignedBam}"
echo "realignedBamIdx: ${realignedBamIdx}"
echo "beforeRecalTable: ${beforeRecalTable}"
echo "BQSRBam: ${BQSRBam}"
echo "BQSRBamIdx: ${BQSRBamIdx}"
echo "BQSRBamMd5: ${BQSRBamMd5}"
echo "externalSampleID: ${externalSampleID}"

makeTmpDir ${BQSRBam}
tmpBQSRBam=${MC_tmpFile}

makeTmpDir ${BQSRBamIdx}
tmpBQSRBamIdx=${MC_tmpFile}

makeTmpDir ${BQSRBamMd5}
tmpBQSRBamMd5=${MC_tmpFile}

#Load GATK module
${stage} GATK/${gatkVersion}
${checkStage}

#Apply GATK BQSR and create output BAM md5sum on the fly
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${gatkJar} \
-T PrintReads \
-R ${indexFile} \
-I ${realignedBam} \
-BQSR ${beforeRecalTable} \
--generate_md5 \
-nct 8 \
-o ${tmpBQSRBam}

#Fix bug in output md5sum creation (echo bqsr bam file name afterwards the md5sum itself, separator are two spaces)
cd ${intermediateDir}
echo -n "  "${externalSampleID}.merged.dedup.realigned.bqsr.bam >> ${tmpBQSRBamMd5}

echo -e "\nQualityScoreRecalibration finished succesfull. Moving temp files to final.\n\n"
mv ${tmpBQSRBam} ${BQSRBam}
mv ${tmpBQSRBamIdx} ${BQSRBamIdx}
mv ${tmpBQSRBamMd5} ${BQSRBamMd5}
