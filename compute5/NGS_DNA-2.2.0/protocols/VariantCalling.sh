#MOLGENIS walltime=23:59:00 mem=8gb ppn=2

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string baitBatchBed
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string projectBatchVariantCalls
#string projectBatchVariantCallsIdx
#string projectBatchVariantCallsMaleNONPAR
#string projectBatchVariantCallsMaleNONPARIdx
#string projectBatchVariantCallsFemale
#string projectBatchVariantCallsFemaleIdx
#string tmpDataDir
#list externalSampleID

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load GATK module
${stage} GATK/${gatkVersion}
${checkStage}

makeTmpDir ${projectBatchVariantCalls}
tmpProjectBatchVariantCalls=${MC_tmpFile}

makeTmpDir ${projectBatchVariantCallsIdx}
tmpProjectBatchVariantCallsIdx=${MC_tmpFile}
makeTmpDir ${projectBatchVariantCallsMaleNONPAR}
tmpProjectBatchVariantCallsMaleNONPAR=${MC_tmpFile}

makeTmpDir ${projectBatchVariantCallsMaleNONPARIdx}
tmpProjectBatchVariantCallsMaleNONPARIdx=${MC_tmpFile} 

makeTmpDir ${projectBatchVariantCallsFemale}
tmpProjectBatchVariantCallsFemale=${MC_tmpFile}

makeTmpDir ${projectBatchVariantCallsFemaleIdx}
tmpProjectBatchVariantCallsFemaleIdx=${MC_tmpFile}

MALE_BAMS=()
BAMS=()
INPUTS=()
for SampleID in "${externalSampleID[@]}"
do
        array_contains INPUTS "$SampleID" || INPUTS+=("$SampleID")    # If bamFile does not exist in array add it
done

for externalID in "${INPUTS[@]}"
do
	
	sex=$(less ${intermediateDir}/${externalID}.chosenSex.txt | awk 'NR==2')
	if [[ $baitBatchBed == *batch-[0-9]*X.bed ]] && [ ${sex} == "Male" ]
	then	
		MALE_BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	else
		BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	fi
done


if [[ ${baitBatchBed} == *batch-[0-9]*X.bed ]]
then

	if [[ ${#MALE_BAMS[@]} > 0 ]]
	then
		echo "X (male): NON AUTOSOMAL REGION"	
		#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
		java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
		$GATK_HOME/${gatkJar} \
		-T HaplotypeCaller \
		-R ${indexFile} \
		${MALE_BAMS[@]} \
		--dbsnp ${dbSNP137Vcf} \
		--genotyping_mode DISCOVERY \
		-stand_emit_conf 10 \
		-stand_call_conf 30 \
		-o ${tmpProjectBatchVariantCallsMaleNONPAR} \
		-L ${baitBatchBed} \
		-ploidy 1 \
		-nct 2
	fi
	if [[ ${#BAMS[@]} > 0 ]]
	then
		echo "X (female)"
		#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        	$GATK_HOME/${gatkJar} \
        	-T HaplotypeCaller \
        	-R ${indexFile} \
        	${BAMS[@]} \
	        --dbsnp ${dbSNP137Vcf} \
       		--genotyping_mode DISCOVERY \
       		-stand_emit_conf 10 \
        	-stand_call_conf 30 \
        	-o ${tmpProjectBatchVariantCallsFemale} \
        	-L ${baitBatchBed} \
        	-ploidy 2 \
        	-nct 2	
	fi
elif [[ $baitBatchBed == *batch-[0-9]*Y.bed ]]
then
	echo "Y"
	if [ ${#BAMS[@]} == 0 ]
        then
                echo "There are no males!"
        else
        	#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        	$GATK_HOME/${gatkJar} \
        	-T HaplotypeCaller \
        	-R ${indexFile} \
        	${BAMS[@]} \
        	--dbsnp ${dbSNP137Vcf} \
        	--genotyping_mode DISCOVERY \
        	-stand_emit_conf 10 \
        	-stand_call_conf 30 \
        	-o ${tmpProjectBatchVariantCalls} \
        	-L ${baitBatchBed} \
        	-ploidy 1 \
        	-nct 2
	fi
else
	echo "Autosomal"
	#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
	java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
	$GATK_HOME/${gatkJar} \
	-T HaplotypeCaller \
	-R ${indexFile} \
	${BAMS[@]} \
	--dbsnp ${dbSNP137Vcf} \
	--genotyping_mode DISCOVERY \
	-stand_emit_conf 10 \
	-stand_call_conf 30 \
	-o ${tmpProjectBatchVariantCalls} \
	-L ${baitBatchBed} \
	-ploidy 2 \
	-nct 2 
fi

if [[ $baitBatchBed == *batch-[0-9]*X.bed ]]
then
	if [ -f ${tmpProjectBatchVariantCallsMaleNONPAR} ] && [ -f  ${tmpProjectBatchVariantCallsFemale} ]
	then
		echo "combine male and female chrX"
		java -Xmx2g -jar ${GATK_HOME}/GenomeAnalysisTK.jar \
		-R ${indexFile} \
   		-T CombineVariants \
		-setKey null \
   		--variant ${tmpProjectBatchVariantCallsMaleNONPAR} \
   		--variant ${tmpProjectBatchVariantCallsFemale} \
		-o ${tmpProjectBatchVariantCalls}

	elif [ ! -f ${tmpProjectBatchVariantCallsMaleNONPAR} ]  
	then
		echo "There are no males"
		tmpProjectBatchVariantCalls=${tmpProjectBatchVariantCallsFemale}
		tmpProjectBatchVariantCallsIdx=${tmpProjectBatchVariantCallsFemaleIdx}
	elif [ ! -f ${tmpProjectBatchVariantCallsFemale} ]
        then
		echo "There are no females!"
                tmpProjectBatchVariantCalls=${tmpProjectBatchVariantCallsMaleNONPAR}
		tmpProjectBatchVariantCallsIdx=${tmpProjectBatchVariantCallsMaleNONPARIdx}
	else
		echo "oops, something is going wrong!"
	fi
fi

echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
if [ -f ${tmpProjectBatchVariantCalls} ]
then
        mv ${tmpProjectBatchVariantCalls} ${projectBatchVariantCalls}
        mv ${tmpProjectBatchVariantCallsIdx} ${projectBatchVariantCallsIdx}
fi
