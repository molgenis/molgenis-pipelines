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
module load Python

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

		##Paste command produces ^M character
		perl -p -i -e "s/\r//g" ${sampleNameID}.combined_bedfile_and_samtoolsoutput.txt

		echo -e "Index\tChr\tChr Position Start\tDescription\tMin Counts\tCDS\tContig" > ${sampleNameID}.coveragePerBase.txt

		awk -v OFS='\t' '{print NR,$1,$2,$5,$7,"CDS","1"}' ${sampleNameID}.combined_bedfile_and_samtoolsoutput.txt >> ${sampleNameID}.coveragePerBase.txt

		if [ ! -f ${capturedBed}.genesOnly ]
		then
			echo "${capturedBed}.genesOnly does not exist (please run make_compute_bedfiles_calculon.sh from the ngs-utils repo)"		
			exit 1
		fi
		
		java -Xmx10g -XX:ParallelGCThreads=4 -jar ${EBROOTGATK}/${gatkJar} \
                -R ${indexFile} \
                -T DepthOfCoverage \
                -o ${sampleNameID}.coveragePerTarget \
                -I ${dedupBam} \
		--omitDepthOutputAtEachBase \
                -L ${capturedBed}

		python ${EBROOTNGSMINUTILS}/calculateCoveragePerGene.py --input ${sampleNameID}.coveragePerBase.txt --output ${sampleNameID}.coveragePerGene.txt.tmp
		sort ${sampleNameID}.coveragePerGene.txt.tmp > ${sampleNameID}.coveragePerGene.txt

		awk -v OFS='\t' '{print $1,$3}' ${sampleNameID}.coveragePerTarget.sample_interval_summary | sed '1d' > ${sampleNameID}.coveragePerTarget.coveragePerTarget.txt.tmp
		paste ${sampleNameID}.coveragePerTarget.coveragePerTarget.txt.tmp ${capturedBed}.genesOnly > ${sampleNameID}.coveragePerTarget_inclGenes.txt
		##Paste command produces ^M character

		perl -p -i -e "s/\r//g" ${sampleNameID}.coveragePerTarget_inclGenes.txt
		
		awk 'BEGIN { OFS = "\t" } ; {split($1,a,":"); print a[1],a[2],$2,$3}' ${sampleNameID}.coveragePerTarget_inclGenes.txt | awk 'BEGIN { OFS = "\t" } ; {split($0,a,"-"); print a[1],a[2]}' > ${sampleNameID}.coveragePerTarget_inclGenes_splitted.txt

		if [ -d ${sampleNameID}.coveragePerTarget_final.txt ]
		then
			rm ${sampleNameID}.coveragePerTarget_final.txt
		fi 

		echo -e "Index\tChr\tChr Position Start\tChr Position End\tAverage Counts\tDescription\tReference Length\tCDS\tContig" > ${sampleNameID}.coveragePerTarget_final.txt
		awk '{OFS="\t"} {len=$3-$2} {print NR,$0,len,"CDS","1"}' ${sampleNameID}.coveragePerTarget_inclGenes_splitted.txt >> ${sampleNameID}.coveragePerTarget_final.txt 


	else
		echo "there is no capturedIntervalsPerBase: ${capturedIntervalsPerBase}, please run coverageperbase: (module load ngs-utils --> run coverage_per_base.sh)" 
	fi
else
	echo "CoveragePerBase skipped"

fi

