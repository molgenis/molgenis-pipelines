#MOLGENIS ppn=4 mem=6gb walltime=03:00:00

#string dedupBam
#string capturedIntervals
#string capturedIntervals_nonAutoChrX
#string indexFileDictionary
#string sample
#string intermediateDir
#string whichSex
#string tempDir
#string checkSexMeanCoverage
#string picardJar
#string hsMetricsNonAutosomalRegionChrX

module load picard
sleep 5

makeTmpDir ${hsMetricsNonAutosomalRegionChrX}
tmpHsMetricsNonAutosomalRegionChrX=${MC_tmpFile}

#make intervallist
if [ -f ${capturedIntervals_nonAutoChrX} ] 
then
	rm ${capturedIntervals_nonAutoChrX}
fi

cp ${indexFileDictionary} ${capturedIntervals_nonAutoChrX}
awk '{if ($0 ~ /^X/){print $0}}' ${capturedIntervals} >> ${capturedIntervals_nonAutoChrX}

#Calculate coverage chromosome X
java -jar -XX:ParallelGCThreads=2 -Xmx4g ${EBROOTPICARD}/${picardJar} CalculateHsMetrics \
INPUT=${dedupBam} \
TARGET_INTERVALS=${capturedIntervals_nonAutoChrX} \
BAIT_INTERVALS=${capturedIntervals_nonAutoChrX} \
TMP_DIR=${tempDir} \
OUTPUT=${tmpHsMetricsNonAutosomalRegionChrX}

rm -rf ${sample}.checkSex.filter.meancoverage.txt

mv ${tmpHsMetricsNonAutosomalRegionChrX} ${hsMetricsNonAutosomalRegionChrX}
echo "mv ${tmpHsMetricsNonAutosomalRegionChrX} ${hsMetricsNonAutosomalRegionChrX}"
