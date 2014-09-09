#MOLGENIS walltime=66:00:00 mem=12gb nodes=1 ppn=1

#Parameter mapping
#string stage
#string checkStage
#string indexFile
#string tempDir
#string RVersion
#string capturingKit
#string targetintervals
#string intermediateDir
#string coveragegatk

#string inputCoverageBam


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "indexFile: ${indexFile}"
echo "tempDir: ${tempDir}"
echo "RVersion: ${RVersion}"
echo "capturingKit: ${capturingKit}"
eche "targetintervals: ${targetintervals}"
echo "intermediateDir: ${intermediateDir}"
echo "inputCoverageBam: ${inputCoverageBam}"

#Check if output exists
alloutputsexist "${coveragegatk}" \
"${coveragegatk}.sample_cumulative_coverage_counts" \
"${coveragegatk}.sample_cumulative_coverage_proportions" \
"${coveragegatk}.sample_interval_statistics" \
"${coveragegatk}.sample_interval_summary" \
"${coveragegatk}.sample_statistics" \
"${coveragegatk}.sample_summary" \
"${coveragegatk}.cumulative_coverage.pdf"

#Get input files
getFile ${indexFile}
getFile ${inputCoverageBam}

if [ ${capturingKit} != "None" ]
then
	getFile ${targetintervals}
fi

#Load GATK module
${stage} GATK/${gatkVersion}
	
#Load R module
${stage} R/${RVersion}
${checkStage}

makeTmpDir ${inputCoverageBam}
tmp_inputCoverageBam=${MC_tmpFile}


if [ ${capturingKit} != "None" ]
then

	java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
	$GATK_HOME/${GATKJar} \
	-T DepthOfCoverage \
	-R ${indexfile} \
	-I ${inputCoverageBam} \
	-o ${coveragegatk} \
	-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50

else

	java -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
	$GATK_HOME/${GATKJar} \
	-T DepthOfCoverage \
	-R ${indexfile} \
	-I ${inputCoverageBam} \
	-o ${coveragegatk} \
	-L ${targetintervals}

fi


#Create coverage graphs for sample

${rscript} ${cumcoveragescriptgatk} \
--in ${coveragegatk}.sample_cumulative_coverage_proportions \
--out ${coveragegatk}.cumulative_coverage.pdf \
--max-depth 100 \
--title "Cumulative coverage ${externalSampleID}"


echo -e "\nCoverageGATK finished succesfull. Moving temp files to final.\n\n"
mv ${coveragegatk}* ${coveragegatk}/
putFile "${coveragegatk}*"

