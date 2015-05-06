#MOLGENIS walltime=23:59:00 mem=4gb ppn=8

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
#string projectChrVariantCalls
#string projectChrVariantCallsIdx
#string projectChrVariantCallsMaleNONPAR
#string projectChrVariantCallsMaleNONPARIdx
#string projectChrVariantCallsFemale
#string projectChrVariantCallsFemaleIdx
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

makeTmpDir ${projectChrVariantCalls}
tmpProjectChrVariantCalls=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsIdx}
tmpProjectChrVariantCallsIdx=${MC_tmpFile}
makeTmpDir ${projectChrVariantCallsMaleNONPAR}
tmpProjectChrVariantCallsMaleNONPAR=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsMaleNONPARIdx}
tmpProjectChrVariantCallsMaleNONPARIdx=${MC_tmpFile} 

makeTmpDir ${projectChrVariantCallsFemale}
tmpProjectChrVariantCallsFemale=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsFemaleIdx}
tmpProjectChrVariantCallsFemaleIdx=${MC_tmpFile}

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
	if [[ $baitBatchBed == *"X"* ]] && [ ${sex} == "Male" ]
	then	
		MALE_BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	else
		BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	fi
done


if [[ ${baitBatchBed} == *"X"* ]]
then

	if [[ ${#MALE_BAMS[@]} > 0 ]]
	then
		echo "X (male): NON AUTOSOMAL REGION"	
		#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
		java -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
		$GATK_HOME/${gatkJar} \
		-T HaplotypeCaller \
		-R ${indexFile} \
		${MALE_BAMS[@]} \
		--dbsnp ${dbSNP137Vcf} \
		--genotyping_mode DISCOVERY \
		-stand_emit_conf 10 \
		-stand_call_conf 30 \
		-o ${tmpProjectChrVariantCallsMaleNONPAR} \
		-L ${baitBatchBed} \
		-ploidy 1 \
		-nct 8
	fi
	if [[ ${#BAMS[@]} > 0 ]]
	then
		echo "X (female)"
		#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        	java -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        	$GATK_HOME/${gatkJar} \
        	-T HaplotypeCaller \
        	-R ${indexFile} \
        	${BAMS[@]} \
	        --dbsnp ${dbSNP137Vcf} \
       		--genotyping_mode DISCOVERY \
       		-stand_emit_conf 10 \
        	-stand_call_conf 30 \
        	-o ${tmpProjectChrVariantCallsFemale} \
        	-L ${baitBatchBed} \
        	-ploidy 2 \
        	-nct 8	
	fi
elif [[ $baitBatchBed == *"Y"* ]]
then
	echo "Y"
	if [ ${#BAMS[@]} == 0 ]
        then
                echo "There are no males!"
        else
		echo "it is a male, diploid for PAR regions on chrX"
        	#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        	java -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
        	$GATK_HOME/${gatkJar} \
        	-T HaplotypeCaller \
        	-R ${indexFile} \
        	${BAMS[@]} \
        	--dbsnp ${dbSNP137Vcf} \
        	--genotyping_mode DISCOVERY \
        	-stand_emit_conf 10 \
        	-stand_call_conf 30 \
        	-o ${tmpProjectChrVariantCalls} \
        	-L ${baitBatchBed} \
        	-ploidy 1 \
        	-nct 8
	fi
else
	echo "Autosomal"
	#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
	java -XX:ParallelGCThreads=16 -Djava.io.tmpdir=${tempDir} -Xmx4g -jar \
	$GATK_HOME/${gatkJar} \
	-T HaplotypeCaller \
	-R ${indexFile} \
	${BAMS[@]} \
	--dbsnp ${dbSNP137Vcf} \
	--genotyping_mode DISCOVERY \
	-stand_emit_conf 10 \
	-stand_call_conf 30 \
	-o ${tmpProjectChrVariantCalls} \
	-L ${baitBatchBed} \
	-ploidy 2 \
	-nct 8 
fi

if [[ $baitBatchBed == *"X"* ]]
then
	if [ -f ${tmpProjectChrVariantCallsMaleNONPAR} ] && [ -f  ${tmpProjectChrVariantCallsFemale} ]
	then
		echo "combine male and female chrX"
		java -Xmx2g -jar ${GATK_HOME}/GenomeAnalysisTK.jar \
		-R ${indexFile} \
   		-T CombineVariants \
		-setKey null \
   		--variant ${tmpProjectChrVariantCallsMaleNONPAR} \
   		--variant ${tmpProjectChrVariantCallsFemale} \
		-o ${tmpProjectChrVariantCalls}

	elif [ ! -f ${tmpProjectChrVariantCallsMaleNONPAR} ]  
	then
		echo "There are no males"
		tmpProjectChrVariantCalls=${tmpProjectChrVariantCallsFemale}
		tmpProjectChrVariantCallsIdx=${tmpProjectChrVariantCallsFemaleIdx}
	elif [ ! -f ${tmpProjectChrVariantCallsFemale} ]
        then
		echo "There are no females!"
                tmpProjectChrVariantCalls=${tmpProjectChrVariantCallsMaleNONPAR}
		tmpProjectChrVariantCallsIdx=${tmpProjectChrVariantCallsMaleNONPARIdx}
	else
		echo "oops, something is going wrong!"
	fi
fi

echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
if [ -f ${tmpProjectChrVariantCalls} ]
then
        mv ${tmpProjectChrVariantCalls} ${projectChrVariantCalls}
        mv ${tmpProjectChrVariantCallsIdx} ${projectChrVariantCallsIdx}
fi
