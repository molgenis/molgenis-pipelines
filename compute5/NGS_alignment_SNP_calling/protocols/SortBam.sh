#MOLGENIS walltime=23:59:00 mem=3gb

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string sortSamJar
#string inputSortBam
#string tmpSortedBam
#string tmpSortedBamIdx
#string tempDir
#string intermediateDir
#string sortedBam
#string sortedBamIdx


#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "sortSamJar: ${sortSamJar}"
echo "inputSortBam: ${inputSortBam}"
echo "tmpSortedBam: ${tmpSortedBam}"
echo "tmpSortedBamIdx: ${tmpSortedBamIdx}"
echo "sortedBam: ${sortedBam}"
echo "sortedBamIdx: ${sortedBamIdx}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"

sleep 10

#Check if output exists
alloutputsexist \
"${sortedBam}" \
"${sortedBamIdx}"

#Get aligned BAM file
getFile ${inputSortBam}

#Load Picard module
${stage} picard-tools/${picardVersion}
${checkStage}

#Run picard, sort BAM file and create index on the fly
java -jar -Xmx3g $PICARD_HOME/${sortSamJar} \
INPUT=${inputSortBam} \
OUTPUT=${tmpSortedBam} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode SortBam: $returnCode\n\n"

if [ $returnCode -eq 0 ]
then
    echo -e "\nSortBam finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpSortedBam} ${sortedBam}
    mv ${tmpSortedBamIdx} ${sortedBamIdx}
    putFile "${sortedBam}"
    putFile "${sortedBamIdx}"
    
else
    echo -e "\nFailed to move SortBam results to ${intermediateDir}\n\n"
    exit -1
fi
