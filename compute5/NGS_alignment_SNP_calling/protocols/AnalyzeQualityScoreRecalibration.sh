#MOLGENIS walltime=01:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string beforeRecalTable
#string postRecalTable
#string BQSRPdf
#string BQSRCsv
#string rVersion
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
echo "beforeRecalTable: ${beforeRecalTable}"
echo "postRecalTable: ${postRecalTable}"
echo "BQSRPdf: ${BQSRPdf}"
echo "BQSRCsv: ${BQSRCsv}"

#Get covariate tables and reference data
getFile ${indexFile}
getFile ${beforeRecalTable}
getFile ${postRecalTable}

#Load GATK module
${stage} GATK/${gatkVersion}
${stage} R/${rVersion}
${checkStage}

makeTmpDir ${BQSRPdf}
tmpBQSRPdf=${MC_tmpFile}

makeTmpDir ${BQSRCsv}
tmpBQSRCsv=${MC_tmpFile}


#Analyze covariates (before and after) using GATK. Afterwards generate statistics and graphs and output as csv and pdf respectively
java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${gatkJar} \
-T AnalyzeCovariates \
-R ${indexFile} \
-before ${beforeRecalTable} \
-after ${postRecalTable} \
-csv ${tmpBQSRCsv} \
-plots ${tmpBQSRPdf}
    echo -e "\nAnalyzeQualityScoreRecalibration finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpBQSRPdf} ${BQSRPdf}
    mv ${tmpBQSRCsv} ${BQSRCsv}
