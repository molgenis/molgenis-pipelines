#MOLGENIS walltime=24:00:00 nodes=1 cores=8 mem=16

#FOREACH sample

picardTools="${picardTools}"
samtools="${samtools}"
faFile=${faFile}
sample=${sample}
declare -a runs=(${ssvQuoted(run)})
declare -a sortedBams=(${ssvQuoted(sortedBam)})
JAVA_HOME=${JAVA_HOME}
gatkVCF=${gatkVCF}

GATKexe=${GATKexe}
tabixDir=${tabixDir}
referenceVCF=${referenceVCF}

editingRepeatsFlankingIntronic=${editingRepeatsFlankingIntronic}
vcflib=${vcflib}
vcftoolsDir=${vcftoolsDir}

<#noparse>

set -o pipefail

#
#
# BAM refactoring
#
#
finalGatkVCF=${gatkVCF}
if [ -s ${finalGatkVCF%vcf}chrX.vcf.gz ]; then
	echo "File exists: ${finalGatkVCF%vcf}chrX.vcf.gz"
	echo "Exiting!"
	exit 1
fi

sampleOutput=${TMPDIR}/
mergedBam=${sampleOutput}/${sample}MergedRuns.bam
resortedBam=${sampleOutput}/${sample}MergedRuns.resorted.bam

echo "bams: ${sortedBams[@]}"
echo "Number of runs: ${#sortedBams[@]}"



#
## Add read groups to each run
#

echo "Adding read groups"
inputline=""
bamsWithReadGroups=()
for (( i=0; i<=$(( ${#sortedBams[@]} -1 )); i++ )) 
do
	run="${runs[${i}]}"
	runBamFile="${sampleOutput}/${run}Aligned.out.sorted.bam"
	cp ${sortedBams[${i}]} ${runBamFile}
		
	${JAVA_HOME}/bin/java \
	-Djava.io.tmpdir=$TMPDIR \
	-Xmx16g \
	-jar ${picardTools}AddOrReplaceReadGroups.jar \
	TMP_DIR=$TMPDIR \
	INPUT=$runBamFile \
	OUTPUT=${sampleOutput}${run}Aligned.out.sorted.grouped.bam \
	RGID=${run} \
	RGLB='1' \
	RGPL='ILLUMINA' \
	RGPU='1' \
	RGSM=${sample} \
	SORT_ORDER=coordinate

	returnCode=$?
	echo "run ${run} add read groups return code: $returnCode"
	bamsWithReadGroups+=(${sampleOutput}${run}Aligned.out.sorted.grouped.bam)
	inputline="${inputline} INPUT=${sampleOutput}${run}Aligned.out.sorted.grouped.bam"
	
done


#
# merge bams for runs
#
echo -e "\nMerging bams"
echo "Merged bam: ${mergedBam}"
echo "bams with read groups to be merged: ${bamsWithReadGroups[@]}"
echo "input line for Picard: ${inputline}"

if [ "${#sortedBams[@]}" -gt "1" ]
then

	${JAVA_HOME}/bin/java \
        -Djava.io.tmpdir=$TMPDIR \
        -Xmx16g \
        -jar ${picardTools}/MergeSamFiles.jar \
        TMP_DIR=$TMPDIR \
        ${inputline} \
        OUTPUT=${mergedBam} \
        USE_THREADING=true
        
	returnCode=$?
	echo "mergeBams return code: $returnCode"
	
	if [ $returnCode -ne 0 ]
	then
		echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
		#Return non zero return code
		exit 1
	else
		echo "Removing runs' bams with read groups:"
		for bam in ${bamsWithReadGroups[@]}
		do
			echo "removing: $bam"
	 		rm $bam
		done
	fi

	echo "bam files merged"
	
	
else 

	 ln -s ${bamsWithReadGroups[0]} ${mergedBam}
	 echo "created symlink for the single bam file to be on same location as merged bam"
	
fi


#
# ReorderSam: this command will reorder your bam file to be in the 1..2..3..4..5..X..Y..MT order. 
#
${JAVA_HOME}/bin/java \
-Djava.io.tmpdir=$TMPDIR \
-Xmx16g \
-jar ${picardTools}ReorderSam.jar \
TMP_DIR=$TMPDIR \
I=${mergedBam} \
O=${resortedBam} \
R=${faFile}

returnCode=$?
echo "ReorderSam return code: $returnCode"

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi
	
#
# Index bam
#
${JAVA_HOME}/bin/java \
-Djava.io.tmpdir=$TMPDIR \
-Xmx16g \
-jar ${picardTools}BuildBamIndex.jar \
TMP_DIR=$TMPDIR \
I=${resortedBam}

returnCode=$?
echo "BAM index return code: $returnCode"

if [ $returnCode -ne 0 ]
then
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi

rm ${mergedBam}
rm ${sampleOutput}${run}Aligned.out.sorted.grouped.bam



#
#
# GATK
#
#

localGatkVCF=${TMPDIR}/${sample}.gatk.vcf
	
echo "localGatkVCF=${localGatkVCF}"
echo "finalGatkVCF=${finalGatkVCF}"


${JAVA_HOME}/bin/java \
-Djava.io.tmpdir=$TMPDIR \
-XX:ParallelGCThreads=2 \
-Xmx16g \
-Xms16g \
-jar $GATKexe \
-T UnifiedGenotyper \
--genotyping_mode GENOTYPE_GIVEN_ALLELES \
--alleles ${referenceVCF} \
-I ${resortedBam} \
-R ${faFile} \
-o ${localGatkVCF}__tmp__ \
-nt 3 \
-nct 8 \
-A BaseCounts \
-stand_call_conf 0 \
-stand_emit_conf 0 \
-out_mode EMIT_ALL_CONFIDENT_SITES \
-allSitePLs \
-U ALLOW_N_CIGAR_READS \
-rf ReassignOneMappingQuality -RMQF 255 -RMQT 60

returnCode=$?
echo "GATK return code: $returnCode"
	

if [ $returnCode -eq 0 ]; then
	
	echo "bgzipping ${localGatkVCF}__tmp__"
	
	${tabixDir}bgzip -f ${localGatkVCF}__tmp__
	zipReturnCode=$?
	echo "Bgzip return code: $zipReturnCode"
	
	if [ $zipReturnCode -eq 0 ]; then
	
		echo "Moving temp file: ${localGatkVCF}__tmp__.gz to ${localGatkVCF}.gz"
		mv ${localGatkVCF}__tmp__.gz ${localGatkVCF}.gz
		mv ${localGatkVCF}__tmp__.idx ${localGatkVCF}.idx
		${tabixDir}tabix -p vcf ${localGatkVCF}.gz
		
	else
		echo "Failed bgzip after GATK"
		exit 1
	fi
else

	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debugging purposes\n\n"
	#Return non zero return code
	exit 1
fi
		
		
#
#
# Filtering
#
#

echo "Filtering"
regionsToFilter=${editingRepeatsFlankingIntronic}
echo "localGatkVCFgz=${localGatkVCF}.gz"
echo "regionsToFilter=${regionsToFilter}"


${vcflib}vcfintersect \
-v \
--bed ${regionsToFilter} \
${localGatkVCF}.gz | \
${tabixDir}bgzip -c \
> ${localGatkVCF%vcf}filtered.vcf.gz__tmp__

filterReturnCode=$?
echo "FilterSNPs return code: $filterReturnCode"

if [ $filterReturnCode -eq 0 ]; then
	echo "Moving temp file: ${localGatkVCF%vcf}filtered.vcf.gz__tmp__ to ${localGatkVCF%vcf}filtered.vcf.gz"
	mv ${localGatkVCF%vcf}filtered.vcf.gz__tmp__ ${localGatkVCF%vcf}filtered.vcf.gz
else
	echo "Filtering failed, not making files final"
	exit 1
fi

#
#
# Split by chromosome
#
#

chromosomes=($(seq 1 22) "X")
for chr in ${chromosomes[@]}
do
	finalGatkVCFchrGz=${finalGatkVCF%vcf}chr${chr}.vcf.gz
	echo "Writing chr${chr} to file: ${finalGatkVCFchrGz}__tmp__"
	
	${vcftoolsDir}vcftools \
		--gzvcf ${localGatkVCF%vcf}filtered.vcf.gz \
		--chr ${chr} \
		--recode-INFO-all \
		--recode-to-stream | \
		${tabixDir}bgzip -c \
		> ${finalGatkVCFchrGz}__tmp__
	splitReturnCode=$?
	echo "splitReturnCode return code: $splitReturnCode"
	
	if [ $splitReturnCode -eq 0 ]; then
		echo "Moving temp file: ${finalGatkVCFchrGz}__tmp__ to ${finalGatkVCFchrGz}"
		mv ${finalGatkVCFchrGz}__tmp__ ${finalGatkVCFchrGz}
	else
		echo "Splitting failed, not making files final"	
	fi
done

</#noparse>