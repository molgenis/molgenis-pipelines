#MOLGENIS walltime=10:00:00 mem=12gb nodes=1 ppn=1

#Parameter mapping
#string gatkVersion
#string gatkJar
#string intermediateDir
#string dedupBam
#string project
#string externalSampleID
#string indexFile
#string capturedIntervalsPerBase
#string capturedBed
#string GCC_Analysis
#string sampleNameID

sleep 5
module load ${gatkVersion}
module load ngs-utils

if [ "${GCC_Analysis}" == "diagnostiek" ] || [ "${GCC_Analysis}" == "diagnostics" ] || [ "${GCC_Analysis}" == "Diagnostiek" ] || [ "${GCC_Analysis}" == "Diagnostics" ]
then
	if [ -f ${capturedIntervalsPerBase} ]
	then
		java -Xmx10g -XX:ParallelGCThreads=4 -jar ${EBROOTGATK}/${gatkJar} \
		-R ${indexFile} \
		-T DepthOfCoverage \
		-o ${sampleNameID}.coveragePerBase \
		--omitLocusTable \
		-I ${dedupBam} \
		-L ${capturedIntervalsPerBase}

		sed '1d' ${sampleNameID}.coveragePerBase > ${sampleNameID}.coveragePerBase_withoutHeader

		paste ${capturedIntervalsPerBase} ${sampleNameID}.coveragePerBase_withoutHeader > ${sampleNameID}.combined_bedfile_and_samtoolsoutput.txt

		echo -e "chr\tstart\tstop\tgene\tcoverage" > ${sampleNameID}.coveragePerBase.txt

		awk -v OFS='\t' '{print $1,$2,$3,$5,$7}' ${sampleNameID}.combined_bedfile_and_samtoolsoutput.txt > ${sampleNameID}.coveragePerBase.txt

		if [ ! -f ${capturedBed}.genesOnly ]
		then
			awk '{print $5 }' ${capturedBed} > ${capturedBed}.genesOnly 
		fi
		
		java -Xmx10g -XX:ParallelGCThreads=4 -jar ${EBROOTGATK}/${gatkJar} \
                -R ${indexFile} \
                -T DepthOfCoverage \
                -o ${sampleNameID}.coveragePerTarget \
                -I ${dedupBam} \
		--omitDepthOutputAtEachBase \
                -L ${capturedBed}
		
		awk -v OFS='\t' '{print $1,$3}' ${sampleNameID}.coveragePerTarget.sample_interval_summary > ${sampleNameID}.coveragePerTarget.coveragePerTarget.txt.tmp
		paste ${sampleNameID}.coveragePerTarget.coveragePerTarget.txt.tmp ${capturedBed}.genesOnly > ${sampleNameID}.coveragePerTarget.coveragePerTarget.txt

		#python ${EBROOTNGSMINUTILS}/calculateCoveragePerGene.py --input ${sampleNameID}.coveragePerBase.txt --output ${sampleNameID}.coveragePerGene.txt.tmp
		#sort ${sampleNameID}.coveragePerGene.txt.tmp > ${sampleNameID}.coveragePerGene.txt

	else
		echo "there is no capturedIntervalsPerBase: ${capturedIntervalsPerBase}, please run coverageperbase: (module load ngs-utils --> run coverage_per_base.sh)" 
	fi
else
	echo "CoveragePerBase skipped"

fi

