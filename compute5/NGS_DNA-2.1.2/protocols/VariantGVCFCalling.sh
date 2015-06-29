#MOLGENIS walltime=23:59:00 mem=12gb ppn=2

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
#string sampleBatchVariantCalls
#string sampleBatchVariantCallsIdx
#string sampleBatchVariantCallsMaleNONPAR
#string sampleBatchVariantCallsMaleNONPARIdx
#string sampleBatchVariantCallsFemale
#string sampleBatchVariantCallsFemaleIdx
#string tmpDataDir
#string externalSampleID

#string realignedBam

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

makeTmpDir ${sampleBatchVariantCalls}
tmpSampleBatchVariantCalls=${MC_tmpFile}

makeTmpDir ${sampleBatchVariantCallsIdx}
tmpSampleBatchVariantCallsIdx=${MC_tmpFile}

makeTmpDir ${sampleBatchVariantCallsMaleNONPAR}
tmpSampleBatchVariantCallsMaleNONPAR=${MC_tmpFile}

makeTmpDir ${sampleBatchVariantCallsMaleNONPARIdx}
tmpSampleBatchVariantCallsMaleNONPARIdx=${MC_tmpFile} 

makeTmpDir ${sampleBatchVariantCallsFemale}
tmpSampleBatchVariantCallsFemale=${MC_tmpFile}

makeTmpDir ${sampleBatchVariantCallsFemaleIdx}
tmpSampleBatchVariantCallsFemaleIdx=${MC_tmpFile}

MALE_BAMS=()
BAMS=()
INPUTS=()
for SampleID in "${externalSampleID[@]}"
do
        array_contains INPUTS "$SampleID" || INPUTS+=("$SampleID")    # If bamFile does not exist in array add it
done

sex=$(less ${intermediateDir}/${externalSampleID}.chosenSex.txt | awk 'NR==2')

baitBatchLength=`cat ${baitBatchBed} | wc -l`

bams=($(printf '%s\n' "${realignedBam[@]}" | sort -u ))
inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

if [ ${baitBatchLength} == 0 ]
then
	echo "skipped ${baitBatchBed}, because the batch is empty"  
else
	if [[ ${baitBatchBed} == *batch-[0-9]*X.bed ]]
	then

		if [ ${sex} == "Male" ]
		then
			echo "X (male): NON AUTOSOMAL REGION"
			java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
			${GATK_HOME}/${gatkJar} \
			-T HaplotypeCaller \
			-R ${indexFile} \
			--dbsnp ${dbSNP137Vcf}\
			${inputs} \
			-dontUseSoftClippedBases \
			-stand_call_conf 10.0 \
			-stand_emit_conf 20.0 \
			-o ${tmpSampleBatchVariantCallsMaleNONPAR} \
			-variant_index_type LINEAR \
			-variant_index_parameter 128000 \
			-L ${baitBatchBed} \
			--emitRefConfidence GVCF \
			-ploidy 1
		elif [ ${sex} == "Female" ]
		then
			echo "X (female)"
			#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        		java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
        		$GATK_HOME/${gatkJar} \
        		-T HaplotypeCaller \
        		-R ${indexFile} \
        		$inputs \
			-dontUseSoftClippedBases \
	        	--dbsnp ${dbSNP137Vcf} \
       			-stand_emit_conf 20.0 \
        		-stand_call_conf 10.0 \
        		-o ${tmpSampleBatchVariantCallsFemale} \
			-variant_index_type LINEAR \
                        -variant_index_parameter 128000 \
        		-L ${baitBatchBed} \
        		--emitRefConfidence GVCF \
			-ploidy 2 
		fi
	elif [[ $baitBatchBed == *batch-[0-9]*Y.bed ]]
	then
		echo "Y"
		if [ ${sex} == "Female" ]
        	then
        	        echo "This sample is not a male, chromosome Y skipped!"
        	elif [ ${sex} == "Male" ]
		then
			java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
                        ${GATK_HOME}/${gatkJar} \
                        -T HaplotypeCaller \
                        -R ${indexFile} \
                        --dbsnp ${dbSNP137Vcf}\
                        ${inputs} \
                        -dontUseSoftClippedBases \
                        -stand_call_conf 10.0 \
                        -stand_emit_conf 20.0 \
                        -o ${tmpSampleBatchVariantCallsMaleNONPAR} \
                        -variant_index_type LINEAR \
                        -variant_index_parameter 128000 \
                        -L ${baitBatchBed} \
                        --emitRefConfidence GVCF \
                        -ploidy 1
		fi
	else
		echo "Autosomal"
		java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
                $GATK_HOME/${gatkJar} \
                -T HaplotypeCaller \
                -R ${indexFile} \
                $inputs \
                -dontUseSoftClippedBases \
                --dbsnp ${dbSNP137Vcf} \
                -stand_emit_conf 20.0 \
                -stand_call_conf 10.0 \
                -o ${tmpSampleBatchVariantCalls} \
                -variant_index_type LINEAR \
                -variant_index_parameter 128000 \
                -L ${baitBatchBed} \
		--emitRefConfidence GVCF \
                -ploidy 2
	fi

	if [[ $baitBatchBed == *batch-[0-9]*X.bed ]]
	then
		if [ -f ${tmpSampleBatchVariantCallsMaleNONPAR} ] && [ -f  ${tmpSampleBatchVariantCallsFemale} ]
		then
			echo "combine male and female chrX"
			java -Xmx2g -jar ${GATK_HOME}/GenomeAnalysisTK.jar \
   			-T CombineGVCFs \
			-R ${indexFile} \
			-setKey null \
   			--variant ${tmpSampleBatchVariantCallsMaleNONPAR} \
   			--variant ${tmpSampleBatchVariantCallsFemale} \
			-o ${tmpSampleBatchVariantCalls}

		elif [ ! -f ${tmpSampleBatchVariantCallsMaleNONPAR} ]  
		then
			echo "There are no males"
			tmpSampleBatchVariantCalls=${tmpSampleBatchVariantCallsFemale}
			tmpSampleBatchVariantCallsIdx=${tmpSampleBatchVariantCallsFemaleIdx}
		elif [ ! -f ${tmpSampleBatchVariantCallsFemale} ]
        	then
			echo "There are no females!"
                	tmpSampleBatchVariantCalls=${tmpSampleBatchVariantCallsMaleNONPAR}
 			tmpSampleBatchVariantCallsIdx=${tmpSampleBatchVariantCallsMaleNONPARIdx}
		else
			echo "oops, something is going wrong!"
		fi
	fi

	echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
	if [ -f ${tmpSampleBatchVariantCalls} ]
	then
        	mv ${tmpSampleBatchVariantCalls} ${sampleBatchVariantCalls}
        	mv ${tmpSampleBatchVariantCallsIdx} ${sampleBatchVariantCallsIdx}
fi
fi
