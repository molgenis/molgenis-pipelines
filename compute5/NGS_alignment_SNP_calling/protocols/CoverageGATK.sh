#MOLGENIS walltime=66:00:00 mem=12gb nodes=1 ppn=1

#Parameter mapping
#string stage
#string checkStage
#string indexFile
#string tempDir
#string RVersion
#string GATKJar
#string GATKVersion
#string capturingKit
#string targetIntervals
#string intermediateDir
#string coverageGATK
#string inputCoverageBam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "indexFile: ${indexFile}"
echo "tempDir: ${tempDir}"
echo "RVersion: ${RVersion}"
echo "capturingKit: ${capturingKit}"
echo "targetIntervals: ${targetIntervals}"
echo "intermediateDir: ${intermediateDir}"
echo "inputCoverageBam: ${inputCoverageBam}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar ${GATKJar}"

#Check if output exists
alloutputsexist "${coverageGATK}" \
"${coverageGATK}.sample_cumulative_coverage_counts" \
"${coverageGATK}.sample_cumulative_coverage_proportions" \
"${coverageGATK}.sample_interval_statistics" \
"${coverageGATK}.sample_interval_summary" \
"${coverageGATK}.sample_statistics" \
"${coverageGATK}.sample_summary" \
"${coverageGATK}.cumulative_coverage.pdf"

#Get input files
getFile ${indexFile}
getFile ${inputCoverageBam}

if [ ${capturingKit} != "None" ]
then
	getFile ${targetIntervals}
fi

#Load GATK module
${stage} GATK/${GATKVersion}
	
#Load R module
${stage} R/${RVersion}
${checkStage}

makeTmpDir ${inputCoverageBam}
tmp_inputCoverageBam=${MC_tmpFile}


if [ ${capturingKit} != "None" ]
then

	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
	$GATK_HOME/${GATKJar} \
	-T DepthOfCoverage \
	-R ${indexFile} \
	-I ${inputCoverageBam} \
	-o ${coverageGATK} \
	-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50

else

	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
	$GATK_HOME/${GATKJar} \
	-T DepthOfCoverage \
	-R ${indexFile} \
	-I ${inputCoverageBam} \
	-o ${coverageGATK} \
	-L ${targetIntervals}

fi


#Create coverage graphs for sample

${rscript} ${cumcoveragescriptgatk} \
--in ${coverageGATK}.sample_cumulative_coverage_proportions \
--out ${coverageGATK}.cumulative_coverage.pdf \
--max-depth 100 \
--title "Cumulative coverage ${externalSampleID}"


echo -e "\nCoverageGATK finished succesfull. Moving temp files to final.\n\n"
#mv ${coverageGATK}* ${coverageGATK}/
#putFile "${coverageGATK}*"

