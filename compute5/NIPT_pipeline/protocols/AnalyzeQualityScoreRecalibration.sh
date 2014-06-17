#MOLGENIS walltime=01:59:00 nodes=1 ppn=8  mem=8gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string beforeRecalTable
#string postRecalTable
#string tmpBQSRPdf
#string BQSRPdf
#string tmpBQSRCsv
#string BQSRCsv



#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "beforeRecalTable: ${beforeRecalTable}"
echo "postRecalTable: ${postRecalTable}"
echo "tmpBQSRPdf: ${tmpBQSRPdf}"
echo "BQSRPdf: ${BQSRPdf}"
echo "tmpBQSRCsv: ${tmpBQSRCsv}"
echo "BQSRCsv: ${BQSRCsv}"
echo "r_libs: ${r_libs}"


sleep 10

#Check if output exists
alloutputsexist \
"${BQSRPdf}" \
"${BQSRCsv}"


#Get covariate tables and reference data
getFile ${indexFile}
getFile ${beforeRecalTable}
getFile ${postRecalTable}


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}



#Analyze covariates (before and after) using GATK. Afterwards generate statistics and graphs and output as csv and pdf respectively
java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
$GATK_HOME/${GATKJar} \
-T AnalyzeCovariates \
-R ${indexFile} \
-before ${beforeRecalTable} \
-after ${postRecalTable} \
-csv ${tmpBQSRCsv} \
-plots ${tmpBQSRPdf}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode AnalyzeQualityScoreRecalibration: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nAnalyzeQualityScoreRecalibration finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpBQSRPdf} ${BQSRPdf}
    mv ${tmpBQSRCsv} ${BQSRCsv}
    putFile "${BQSRPdf}"
    putFile "${BQSRCsv}"
    
else
    echo -e "\nFailed to move AnalyzeQualityScoreRecalibration results to ${intermediateDir}\n\n"
    exit -1
fi
