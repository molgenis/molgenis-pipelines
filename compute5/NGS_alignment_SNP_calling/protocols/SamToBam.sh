#MOLGENIS walltime=23:59:00 mem=3

#Parameter mapping
#string stage
#string picardVersion
#string samToBamJar
#string alignedSam
#string tmpAlignedBam
#string alignedBam
#string tempDir
#string intermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "picardVersion: ${picardVersion}"
echo "samToBamJar: ${samToBamJar}"
echo "alignedSam: ${alignedSam}"
echo "tmpAlignedBam: ${tmpAlignedBam}"
echo "alignedBam: ${alignedBam}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"


#Check if output exists
alloutputsexist \
"${alignedBam}"

#Get aligned SAM file
getFile ${alignedSam}

#Load Picard module
${stage} picard/${picardVersion}
${checkStage}

#Run picard, convert SAM to BAM
java -jar -Xmx3g ${samToBamJar} \
INPUT=${alignedSam} \
OUTPUT=${tmpAlignedBam} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode SamToBam: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nSamToBam finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpAlignedBam} ${alignedBam}
    putFile "${alignedBam}"
    
else
    echo -e "\nFailed to move SamToBam results to ${intermediateDir}\n\n"
    exit -1
fi