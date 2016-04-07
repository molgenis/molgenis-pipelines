#MOLGENIS walltime=23:59:00 mem=14gb ppn=2

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string capturedBatchBed
#string femaleCapturedBatchBed
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
#string	project
#string logsDir
#string dedupBam

sleep 5

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Load GATK module
${stage} ${gatkVersion}
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

baitBatchLength=`cat ${capturedBatchBed} | wc -l`

bams=($(printf '%s\n' "${dedupBam[@]}" | sort -u ))
inputs=$(printf ' -I %s ' $(printf '%s\n' ${bams[@]}))

if [ ${baitBatchLength} -eq 0 ]
then
	echo "skipped ${capturedBatchBed}, because the batch is empty"  
else
	if [[ ${capturedBatchBed} == *batch-[0-9]*X.bed ]]
	then

		if [ "${sex}" == "Male" ]
		then
			echo "X (male): NON AUTOSOMAL REGION"
			java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
			${EBROOTGATK}/${gatkJar} \
			-T HaplotypeCaller \
			-R ${indexFile} \
			--dbsnp ${dbSNP137Vcf}\
			${inputs} \
			-dontUseSoftClippedBases \
			-stand_call_conf 10.0 \
			-stand_emit_conf 20.0 \
			-o ${tmpSampleBatchVariantCalls} \
			-L ${capturedBatchBed} \
			--emitRefConfidence GVCF \
			-ploidy 2
		elif [[ "${sex}" == "Female" || "${sex}" == "Unknown" ]]
		then
			echo "X (female)"
			#Run GATK HaplotypeCaller in DISCOVERY mode to call SNPs and indels
        		java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
        		${EBROOTGATK}/${gatkJar} \
        		-T HaplotypeCaller \
        		-R ${indexFile} \
        		$inputs \
			-dontUseSoftClippedBases \
	        	--dbsnp ${dbSNP137Vcf} \
       			-stand_emit_conf 20.0 \
        		-stand_call_conf 10.0 \
        		-o ${tmpSampleBatchVariantCalls} \
        		-L ${capturedBatchBed} \
        		--emitRefConfidence GVCF \
			-ploidy 2 
		else 
			echo "The sex has not a known option (Male, Female, Unknown)"
			exit 1
		fi
	elif [[ "${capturedBatchBed}" == *batch-[0-9]*Y.bed ]]
	then
		echo "Y"
		if [[ "${sex}" == "Female" || "${sex}" == "Unknown" ]]
        	then
			java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
                        ${EBROOTGATK}/${gatkJar} \
                        -T HaplotypeCaller \
                        -R ${indexFile} \
                        --dbsnp ${dbSNP137Vcf}\
                        ${inputs} \
                        -dontUseSoftClippedBases \
                        -stand_call_conf 10.0 \
                        -stand_emit_conf 20.0 \
                        -o ${tmpSampleBatchVariantCalls} \
                        -L ${femaleCapturedBatchBed} \
                        --emitRefConfidence GVCF \
                        -ploidy 2
        	elif [ "${sex}" == "Male" ]
		then
			java -Xmx12g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -jar \
                        ${EBROOTGATK}/${gatkJar} \
                        -T HaplotypeCaller \
                        -R ${indexFile} \
                        --dbsnp ${dbSNP137Vcf}\
                        ${inputs} \
                        -dontUseSoftClippedBases \
                        -stand_call_conf 10.0 \
                        -stand_emit_conf 20.0 \
                        -o ${tmpSampleBatchVariantCalls} \
                        -L ${capturedBatchBed} \
                        --emitRefConfidence GVCF \
                        -ploidy 2
		fi
	else
		echo "Autosomal"
		java -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tempDir} -Xmx12g -jar \
                ${EBROOTGATK}/${gatkJar} \
                -T HaplotypeCaller \
                -R ${indexFile} \
                $inputs \
                -dontUseSoftClippedBases \
                --dbsnp ${dbSNP137Vcf} \
                -stand_emit_conf 20.0 \
                -stand_call_conf 10.0 \
                -o ${tmpSampleBatchVariantCalls} \
                -L ${capturedBatchBed} \
		--emitRefConfidence GVCF \
                -ploidy 2
	fi

	echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
	if [ -f "${tmpSampleBatchVariantCalls}" ]
	then
        	mv ${tmpSampleBatchVariantCalls} ${sampleBatchVariantCalls}
        	mv ${tmpSampleBatchVariantCallsIdx} ${sampleBatchVariantCallsIdx}
fi
fi
