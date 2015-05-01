#MOLGENIS walltime=23:59:00 mem=4gb ppn=16

#Parameter mapping
#string stage
#string checkStage
#string gatkVersion
#string gatkJar
#string tempDir
#string intermediateDir
#string indexFile
#string baitChrBed
#string dbSNP137Vcf
#string dbSNP137VcfIdx
#string projectChrVariantCalls
#string projectChrVariantCallsIdx
#string projectChrVariantCallsMaleNONPAR
#string projectChrVariantCallsMaleNONPARIdx
#string projectChrVariantCallsMalePAR
#string projectChrVariantCallsMalePARIdx
#string projectChrVariantCallsFemale
#string projectChrVariantCallsFemaleIdx
#string projectVariantsMaleMerged
#list externalSampleID
#string tmpDataDir

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "gatkVersion: ${gatkVersion}"
echo "gatkJar: ${gatkJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "baitChrBed: ${baitChrBed}"
echo "dbSNP137Vcf: ${dbSNP137Vcf}"
echo "dbSNP137VcfIdx: ${dbSNP137VcfIdx}"


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

makeTmpDir ${projectChrVariantCallsMalePAR}
tmpProjectChrVariantCallsMalePAR=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsMalePARIdx}
tmpProjectChrVariantCallsMalePARIdx=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsFemale}
tmpProjectChrVariantCallsFemale=${MC_tmpFile}

makeTmpDir ${projectChrVariantCallsFemaleIdx}
tmpProjectChrVariantCallsFemaleIdx=${MC_tmpFile}

makeTmpDir ${projectVariantsMaleMerged}
tmpProjectVariantsMaleMerged=${MC_tmpFile}

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
	if [[ $baitChrBed == *"chrX"* ]] && [ ${sex} == "Male" ]
	then	
 		MALE_BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	else
		BAMS+=("-I ${intermediateDir}/$externalID.merged.dedup.realigned.bam")
	fi
done


if [[ $baitChrBed == *"chrX"* ]]
then
	awk '
	{
	if (($2 >= 60001  && $3 <= 2699520 ) || ($2 >= 154931044 && $3 <= 155260560 )){
	        print $0 >> "${intermediateDir}/chrX.par.bed"
	} else {
	        print $0 >> "${intermediateDir}/chrX.nonpar.bed"
	}
	}' ${baitChrBed}

	if [[ ${#MALE_BAMS[@]} > 0 ]]
	then
		echo "X (male): NON AUTOSOMAL REGION"	
		echo "it is a male, NON HOMOLOGOUS REGION"
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
		-L ${intermediateDir}/chrX.nonpar.bed \
		-ploidy 1 \
		-nct 16

		echo "X (male): PAR REGIONS"
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
        	-o ${tmpProjectChrVariantCallsMalePAR} \
        	-L ${intermediateDir}/chrX.par.bed \
  		-ploidy 2 \
       		-nct 16
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
        	-L ${baitChrBed} \
        	-ploidy 2 \
        	-nct 16	
	fi
elif [[ $baitChrBed == *"chrY"* ]]
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
        	-L ${baitChrBed} \
        	-ploidy 1 \
        	-nct 16
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
	-L ${baitChrBed} \
	-ploidy 2 \
	-nct 16 
fi

echo -e "\nVariantCalling finished succesfull. Moving temp files to final.\n\n"
if [ -f ${tmpProjectChrVariantCalls} ]
then
	mv ${tmpProjectChrVariantCalls} ${projectChrVariantCalls}
	mv ${tmpProjectChrVariantCallsIdx} ${projectChrVariantCallsIdx}
fi

if [[ $baitChrBed == *"chrX"* ]]
then
	if [ ${#MALE_BAMS[@]} == 0 ]
        then
                echo "There are no males!"
        else	
		echo "concatenate male chrX PAR region with non-PAR region"
		mv ${tmpProjectChrVariantCallsMaleNONPAR} ${projectChrVariantCallsMaleNONPAR}
		mv ${tmpProjectChrVariantCallsMaleNONPARIdx} ${projectChrVariantCallsMaleNONPARIdx}

		mv ${tmpProjectChrVariantCallsMalePAR} ${projectChrVariantCallsMalePAR}
		mv ${tmpProjectChrVariantCallsMalePARIdx} ${projectChrVariantCallsMalePARIdx}

		java -cp ${GATK_HOME}/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants \
	        -R ${indexFile} \
       		--variant ${projectChrVariantCallsMaleNONPAR} \
        	--variant ${projectChrVariantCallsMalePAR} \
        	-out ${tmpProjectVariantsMaleMerged} \
        	-assumeSorted

		mv ${tmpProjectVariantsMaleMerged} ${projectVariantsMaleMerged}
	fi
	
	if [ ${#BAMS[@]} == 0 ]
	then	
                echo "There are no females!"
        else
		 mv ${tmpProjectChrVariantCallsFemale} ${projectChrVariantCallsFemale}
	fi
		
	if [ -f ${projectVariantsMaleMerged} ] && [ -f  ${projectChrVariantCallsFemale} ]
	then
		echo "combine male and female chrX"
		java -Xmx2g -jar ${GATK_HOME}/GenomeAnalysisTK.jar \
		-R ${indexFile} \
   		-T CombineVariants \
   		--variant ${projectVariantsMaleMerged} \
   		--variant ${projectChrVariantCallsFemale} \
   		-o ${projectPrefix}.chrX.variant.calls.vcf
	fi
fi
