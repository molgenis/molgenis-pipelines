#MOLGENIS walltime=23:59:00 mem=4gb nodes=1 ppn=8

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string dedupBam
#string dedupBamIdx
#string beforeRecalTable
#string tmpBQSRBam
#string tmpBQSRBamIdx
#string BQSRBam
#string BQSRBamIdx
#string tmpBQSRBamMd5
#string BQSRBamMd5
#string tmpTmpBQSRBamMd5
#string externalSampleID


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "dedupBam: ${dedupBam}"
echo "dedupBamIdx: ${dedupBamIdx}"
echo "beforeRecalTable: ${beforeRecalTable}"
echo "tmpBQSRBam: ${tmpBQSRBam}"
echo "tmpBQSRBamIdx: ${tmpBQSRBamIdx}"
echo "BQSRBam: ${BQSRBam}"
echo "BQSRBamIdx: ${BQSRBamIdx}"
echo "tmpBQSRBamMd5: ${tmpBQSRBamMd5}"
echo "BQSRBamMd5: ${BQSRBamMd5}"
echo "tmpTmpBQSRBamMd5: ${tmpTmpBQSRBamMd5}"
echo "externalSampleID: ${externalSampleID}"


sleep 10

#Check if output exists
alloutputsexist \
"${BQSRBam}" \
"${BQSRBamIdx}" \
"${BQSRBamMd5}"


#Get BAM file and reference data
getFile ${dedupBam}
getFile ${dedupBamIdx}
getFile ${indexFile}
getFile ${beforeRecalTable}


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}

#Apply GATK BQSR and create output BAM md5sum on the fly
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T PrintReads \
-R ${indexFile} \
-I ${dedupBam} \
-BQSR ${beforeRecalTable} \
--generate_md5 \
-nct 8 \
-o ${tmpBQSRBam}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode QualityScoreRecalibration: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
        #Fix bug in output md5sum creation (echo bqsr bam file name afterwards the md5sum itself, separator are two spaces)
        cd ${intermediateDir}
        cat ${tmpBQSRBamMd5} > ${tmpTmpBQSRBamMd5}
        echo -n "  "${externalSampleID}.merged.dedup.bqsr.bam >> ${tmpTmpBQSRBamMd5}
        rm ${tmpBQSRBamMd5}

    echo -e "\nQualityScoreRecalibration finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpBQSRBam} ${BQSRBam}
    mv ${tmpBQSRBamIdx} ${BQSRBamIdx}
    mv ${tmpTmpBQSRBamMd5} ${BQSRBamMd5}
    putFile "${BQSRBam}"
    putFile "${BQSRBamIdx}"
    putFile "${BQSRBamMd5}"
    
else
    echo -e "\nFailed to move QualityScoreRecalibration results to ${intermediateDir}\n\n"
    exit -1
fi
