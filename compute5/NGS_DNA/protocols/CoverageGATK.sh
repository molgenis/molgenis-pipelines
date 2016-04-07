#MOLGENIS walltime=66:00:00 mem=14gb nodes=1 ppn=1

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string indexFile
#string tempDir
#string rVersion
#string gatkJar
#string gatkVersion
#string capturingKit
#string capturedIntervals
#string intermediateDir
#string coverageGATK
#string cumCoverageScriptGATK
#string inputCoverageBam
#string tmpDataDir
#string project
#string logsDir

if [ ${capturingKit} != "None" ]
then
	getFile ${capturedIntervals}
fi

#Load GATK module
${stage} ${gatkVersion}
	
#Load R module
${stage} R/${rVersion}
${checkStage}

makeTmpDir ${inputCoverageBam}
tmp_inputCoverageBam=${MC_tmpFile}


if [ ${capturingKit} != "None" ]
then

	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
	$EBROOT${gatkJar} \
	-mte \
	-T DepthOfCoverage \
	-R ${indexFile} \
	-I ${inputCoverageBam} \
	-o ${coverageGATK} \
	-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50

else

	java -XX:ParallelGCThreads=4 -Djava.io.tmpdir=${tempdir} -Xmx12g -jar \
	$EBROOT${gatkJar} \
	-T DepthOfCoverage \
	-mte \
	-R ${indexFile} \
	-I ${inputCoverageBam} \
	-o ${coverageGATK} \
	-ct 1 -ct 2 -ct 5 -ct 10 -ct 15 -ct 20 -ct 30 -ct 40 -ct 50 \
	-L ${capturedIntervals}

fi

#Create coverage graphs for sample

Rscript ${cumCoverageScriptGATK} \
--in ${coverageGATK}.sample_cumulative_coverage_proportions \
--out ${coverageGATK}.cumulative_coverage.pdf \
--max-depth 100 \
--title "Cumulative coverage ${externalSampleID}"

echo -e "\nCoverageGATK finished succesfull. Moving temp files to final.\n\n"
#mv ${coverageGATK}* ${coverageGATK}/


