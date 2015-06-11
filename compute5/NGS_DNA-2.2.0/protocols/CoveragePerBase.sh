#MOLGENIS walltime=10:00:00 mem=12gb nodes=1 ppn=1

#Parameter mapping
#string gatkVersion
#string intermediateDir
#string realignedBam
#string project
#string sample
#string indexFile
#string targetIntervalsPerBase
#string baitBed
#string GCC_Analysis
#string scriptDir


sleep 10
module load GATK/${gatkVersion}

if [ $GCC_Analysis == "diagnostiek" ] || [ $GCC_Analysis == "diagnostics" ]
then
	if [ -f ${targetIntervalsPerBase} ]
	then
		java -Xmx2g -jar $GATK_HOME/GenomeAnalysisTK.jar \
		-R ${indexFile} \
		-T DepthOfCoverage \
		-o ${sample}.samtools.coveragePerBase \
		-I ${realignedBam} \
		-L ${targetIntervalsPerBase}

		sed '1d' ${sample}.samtools.coveragePerBase > ${sample}.samtools.coveragePerBase_withoutHeader
	
		paste ${targetIntervalsPerBase} ${sample}.samtools.coveragePerBase_withoutHeader > ${sample}.combined_bedfile_and_samtoolsoutput.txt

		echo -e "chr\tstart\tstop\tgene\tcoverage" > ${sample}.coveragePerBase.txt

		awk -v OFS='\t' '{print $1,$2,$3,$5,$7}' ${sample}.combined_bedfile_and_samtoolsoutput.txt >> ${sample}.coveragePerBase.txt
	else
		echo "there is no targetIntervalsPerBase: ${targetIntervalsPerBase}, please run coverageperbase: ${scriptDir}/coverage_per_base.sh" 
	fi
else
	echo "CoveragePerBase skipped"

fi
