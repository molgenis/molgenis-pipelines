#MOLGENIS walltime=23:59:00 mem=3gb

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string samToBamJar
#string alignedSam
#string tmpAlignedBam
#string tempDir
#string intermediateDir
#string alignedBam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "samToBamJar: ${samToBamJar}"
echo "alignedSam: ${alignedSam}"
echo "tmpAlignedBam: ${tmpAlignedBam}"
echo "alignedBam: ${alignedBam}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"

sleep 10

#Check if output exists
alloutputsexist \
"${alignedBam}"

#Get aligned SAM file
getFile ${alignedSam}

#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}

#Run picard, convert SAM to BAM
java -jar -Xmx3g $PICARD_HOME/${samToBamJar} \
INPUT=${alignedSam} \
OUTPUT=${tmpAlignedBam} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode SamToBam: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nSamToBam finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpAlignedBam} ${alignedBam}
    putFile "${alignedBam}"
    
else
    echo -e "\nFailed to move SamToBam results to ${intermediateDir}\n\n"
    exit -1
fi
