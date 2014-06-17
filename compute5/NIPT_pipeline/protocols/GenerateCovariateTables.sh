#MOLGENIS walltime=23:59:00 mem=8gb nodes=1 ppn=8

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string KGPhase1IndelsVcf
#string KGPhase1IndelsVcfIdx
#string MillsGoldStandardIndelsVcf
#string MillsGoldStandardIndelsVcfIdx
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string inputRecal
#string inputGenerateCovariateTablesBam
#string inputGenerateCovariateTablesBamIdx
#string inputGenerateCovariateTablesTable
#string tmpOutputGenerateCovariateTablesTable
#string outputGenerateCovariateTablesTable


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "KGPhase1IndelsVcf: ${KGPhase1IndelsVcf}"
echo "KGPhase1IndelsVcfIdx: ${KGPhase1IndelsVcfIdx}"
echo "MillsGoldStandardIndelsVcf: ${MillsGoldStandardIndelsVcf}"
echo "MillsGoldStandardIndelsVcfIdx: ${MillsGoldStandardIndelsVcfIdx}"
echo "dbSNP137Vcf: ${dbSNP137Vcf}"
echo "dbSNP137VcfIdx: ${dbSNP137VcfIdx}"
echo "inputRecal: ${inputRecal}"
echo "inputGenerateCovariateTablesBam: ${inputGenerateCovariateTablesBam}"
echo "inputGenerateCovariateTablesBamIdx: ${inputGenerateCovariateTablesBamIdx}"
echo "inputGenerateCovariateTablesTable: ${inputGenerateCovariateTablesTable}"
echo "tmpOutputGenerateCovariateTablesTable: ${tmpOutputGenerateCovariateTablesTable}"
echo "outputGenerateCovariateTablesTable: ${outputGenerateCovariateTablesTable}"


sleep 10

#Check if output exists
alloutputsexist \
"${outputGenerateCovariateTablesTable}"

#Get dedupped BAM file and reference data
getFile ${inputGenerateCovariateTablesBam}
getFile ${inputGenerateCovariateTablesBamIdx}
getFile ${indexFile}
getFile ${KGPhase1IndelsVcf}
getFile ${KGPhase1IndelsVcfIdx}
getFile ${MillsGoldStandardIndelsVcf}
getFile ${MillsGoldStandardIndelsVcfIdx}
getFile ${dbSNP137Vcf}
getFile ${dbSNP137VcfIdx}
if [ ${inputRecal} == "post" ]
then
        getFile ${inputGenerateCovariateTablesTable}
fi


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}


#If variable recal is "post" apply the recal.table to calculate improvement in metrics.
if [ ${inputRecal} == "before" ]
then
        java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        $GATK_HOME/${GATKJar} \
        -T BaseRecalibrator \
        -R ${indexFile} \
        -I ${inputGenerateCovariateTablesBam} \
        -knownSites ${KGPhase1IndelsVcf} \
        -knownSites ${MillsGoldStandardIndelsVcf} \
        -knownSites ${dbSNP137Vcf} \
        -nct 8 \
        -o ${tmpOutputGenerateCovariateTablesTable}

elif [ ${inputRecal} == "post" ]
then
        java -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        $GATK_HOME/${GATKJar} \
        -T BaseRecalibrator \
        -R ${indexFile} \
        -I ${inputGenerateCovariateTablesBam} \
        -knownSites ${KGPhase1IndelsVcf} \
        -knownSites ${MillsGoldStandardIndelsVcf} \
        -knownSites ${dbSNP137Vcf} \
        -BQSR ${inputGenerateCovariateTablesTable} \
        -nct 8 \
        -o ${tmpOutputGenerateCovariateTablesTable}

else
        echo -e "Variable inputRecal: ${inputRecal} does not contain a valid value.\n Valid values are "before" or "post".\n Please fix this and rerun the protocol.\n"

fi

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode GenerateCovariateTables: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nGenerateCovariateTables finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpOutputGenerateCovariateTablesTable} ${outputGenerateCovariateTablesTable}
    putFile "${outputGenerateCovariateTablesTable}"
    
else
    echo -e "\nFailed to move GenerateCovariateTables results to ${intermediateDir}\n\n"
    exit -1
fi
