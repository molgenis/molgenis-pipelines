#MOLGENIS walltime=23:59:00 mem=4gb ppn=8

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
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
#string outputGenerateCovariateTablesTable
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
echo "outputGenerateCovariateTablesTable: ${outputGenerateCovariateTablesTable}"

#Load GATK module
${stage} GATK/${gatkVersion}
${checkStage}

makeTmpDir ${outputGenerateCovariateTablesTable}
tmpOutputGenerateCovariateTablesTable=${MC_tmpFile}

#If variable recal is "post" apply the recal.table to calculate improvement in metrics.
if [ ${inputRecal} == "before" ]
then
	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
	$GATK_HOME/${gatkJar} \
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
	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
	$GATK_HOME/${gatkJar} \
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
    echo -e "\nGenerateCovariateTables finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpOutputGenerateCovariateTablesTable} ${outputGenerateCovariateTablesTable}

