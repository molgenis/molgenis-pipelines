#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
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

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
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

sleep 10

#Check if output exists
alloutputsexist \
"${BQSRBam}" \
"${BQSRBamIdx}" \
"${BQSRBamMd5}"

makeTmpDir ${BQSRBam}
tmpBQSRBam=${MC_tmpFile}

makeTmpDir ${BQSRBamIdx}
tmpBQSRBamIdx=${MC_tmpFile}

makeTmpDir ${BQSRBamMd5}
tmpBQSRBamMd5=${MC_tmpFile}

#Get realigned BAM file and reference data
getFile ${realignedBam}
getFile ${realignedBamIdx}
getFile ${indexFile}
getFile ${beforeRecalTable}

#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

#Apply GATK BQSR and create output BAM md5sum on the fly
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
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
    putFile "${BQSRBam}"
    putFile "${BQSRBamIdx}"
    putFile "${BQSRBamMd5}"
