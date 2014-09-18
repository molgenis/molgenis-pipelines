#MOLGENIS walltime=23:59:00 mem=4gb

#Parameter mapping
#string stage
#string checkStage
#string GATKVersion
#string GATKJar
#string tempDir
#string intermediateDir
#string indexFile
#string projectSNPsMerged
#string projectSNPsMergedFiltered

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "GATKVersion: ${GATKVersion}"
echo "GATKJar: ${GATKJar}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"
echo "indexFile: ${indexFile}"
echo "projectSNPsMerged: ${projectSNPsMerged}"
echo "projectSNPsMergedFiltered: ${projectSNPsMergedFiltered}"

sleep 10

#Function to check if array contains value
array_contains () { 
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${array[@]}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Check if output exists
alloutputsexist \
"${projectSNPsMergedFiltered}"

INPUTS=()

#Get BQSR BAM, idx file and resources
getFile ${indexFile}
getFile ${projectSNPsMerged}


#Load GATK module
${stage} GATK/${GATKVersion}
${checkStage}


makeTmpDir ${projectSNPsMergedFiltered}
tmp_projectSNPsMergedFiltered=${MC_tmpFile}

#Run GATK VariantFiltration to filter called SNPs on 

java -XX:ParallelGCThreads=4 -Xmx8g -Xms6g -jar $GATK_HOME/${GATKJar} \
-T VariantFiltration \
-R ${indexFile} \
-o ${tmp_projectSNPsMergedFiltered} \
--variant ${projectSNPsMerged} \
--genotypeFilterExpression \
"QD < 2.0 && \
MQ < 40.0 && \
FS > 60.0 && \
HaplotypeScore > 13.0 && \
MQRankSum < -12.5 && \
ReadPosRankSum < -8.0" \
--genotypeFilterName "FILTQDP"


echo -e "\nVariantFiltering finished succesfull. Moving temp files to final.\n\n"
mv ${tmp_projectSNPsMergedFiltered} ${projectSNPsMergedFiltered}

