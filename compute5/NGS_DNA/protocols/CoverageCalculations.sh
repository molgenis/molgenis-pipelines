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
#string coveragePerBaseDir
#string coveragePerTargetDir
#string ngsUtilsVersion
#string pythonVersion

sleep 5
module load ${gatkVersion}
module load ${ngsUtilsVersion}
module load ${pythonVersion}

if [ "${GCC_Analysis}" == "diagnostiek" ] || [ "${GCC_Analysis}" == "diagnostics" ] || [ "${GCC_Analysis}" == "Diagnostiek" ] || [ "${GCC_Analysis}" == "Diagnostics" ]
then
	if [ -f ${capturedIntervalsPerBase} ]
	then
		### Per base bed files
		for i in $(ls -d ${coveragePerBaseDir}/*)
		do
			perBase=$(basename $i)
			perBaseDir=${coveragePerBaseDir}/${perBase}/human_g1k_v37/
			java -Xmx10g -XX:ParallelGCThreads=4 -jar ${EBROOTGATK}/${gatkJar} \
			-R ${indexFile} \
			-T DepthOfCoverage \
			-o ${sampleNameID}.${perBase}.coveragePerBase \
			--omitLocusTable \
			-I ${dedupBam} \
			-L ${perBaseDir}/${perBase}.bed

			sed '1d' ${sampleNameID}.${perBase}.coveragePerBase > ${sampleNameID}.${perBase}.coveragePerBase_withoutHeader

			paste ${perBaseDir}/${perBase}.uniq.per_base.bed ${sampleNameID}.${perBase}.coveragePerBase_withoutHeader > ${sampleNameID}.${perBase}.combined_bedfile_and_samtoolsoutput.txt

			##Paste command produces ^M character
			perl -p -i -e "s/\r//g" ${sampleNameID}.${perBase}.combined_bedfile_and_samtoolsoutput.txt

			echo -e "Index\tChr\tChr Position Start\tDescription\tMin Counts\tCDS\tContig" > ${sampleNameID}.${perBase}.coveragePerBase.txt

			awk -v OFS='\t' '{print NR,$1,$2,$5,$7,"CDS","1"}' ${sampleNameID}.${perBase}.combined_bedfile_and_samtoolsoutput.txt >> ${sampleNameID}.${perBase}.coveragePerBase.txt
		done
		
		## Per target bed files
		for i in $(ls -d ${coveragePerTargetDir}/*)
		do
			perTarget=$(basename $i)
			perTargetDir=${coveragePerTargetDir}/${perTarget}/human_g1k_v37/

		java -Xmx10g -XX:ParallelGCThreads=4 -jar ${EBROOTGATK}/${gatkJar} \
                -R ${indexFile} \
                -T DepthOfCoverage \
                -o ${sampleNameID}.${perTarget}.coveragePerTarget \
                -I ${dedupBam} \
		--omitDepthOutputAtEachBase \
                -L ${perTargetDir}/${perTarget}.bed

		awk -v OFS='\t' '{print $1,$3}' ${sampleNameID}.${perTarget}.coveragePerTarget.sample_interval_summary | sed '1d' > ${sampleNameID}.${perTarget}.coveragePerTarget.coveragePerTarget.txt.tmp
		paste ${sampleNameID}.${perTarget}.coveragePerTarget.coveragePerTarget.txt.tmp ${perTargetDir}/${perTarget}.genesOnly > ${sampleNameID}.${perTarget}.coveragePerTarget_inclGenes.txt
		##Paste command produces ^M character

		perl -p -i -e "s/\r//g" ${sampleNameID}.${perTarget}.coveragePerTarget_inclGenes.txt
		
		awk 'BEGIN { OFS = "\t" } ; {split($1,a,":"); print a[1],a[2],$2,$3}' ${sampleNameID}.${perTarget}.coveragePerTarget_inclGenes.txt | awk 'BEGIN { OFS = "\t" } ; {split($0,a,"-"); print a[1],a[2]}' > ${sampleNameID}.${perTarget}.coveragePerTarget_inclGenes_splitted.txt

		if [ -d ${sampleNameID}.${perTarget}.coveragePerTarget_final.txt ]
		then
			rm ${sampleNameID}.${perTarget}.coveragePerTarget_final.txt
		fi 

		echo -e "Index\tChr\tChr Position Start\tChr Position End\tAverage Counts\tDescription\tReference Length\tCDS\tContig" > ${sampleNameID}.${perTarget}.coveragePerTarget_final.txt
		awk '{OFS="\t"} {len=$3-$2} {print NR,$0,len,"CDS","1"}' ${sampleNameID}.${perTarget}.coveragePerTarget_inclGenes_splitted.txt >> ${sampleNameID}.${perTarget}.coveragePerTarget_final.txt 
		done

	else
		echo "there is no capturedIntervalsPerBase: ${capturedIntervalsPerBase}, please run coverageperbase: (module load ngs-utils --> run coverage_per_base.sh)" 
	fi
else
	echo "CoveragePerBase skipped"

fi

