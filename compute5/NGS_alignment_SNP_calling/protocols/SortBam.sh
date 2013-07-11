#MOLGENIS walltime=23:59:00 mem=3

#Parameter mapping
#string stage
#string picardVersion
#string sortSamJar
#string inputBam
#string tmpSortedBam
#string tmpSortedBamIdx
#string sortedBam
#string sortedBamIdx
#string tempDir
#string intermediateDir


#Echo parameter values
echo "stage: ${stage}"
echo "picardVersion: ${picardVersion}"
echo "sortSamJar: ${sortSamJar}"
echo "inputBam: ${inputBam}"
echo "tmpSortedBam: ${tmpSortedBam}"
echo "tmpSortedBamIdx: ${tmpSortedBamIdx}"
echo "sortedBam: ${sortedBam}"
echo "sortedBamIdx: ${sortedBamIdx}"
echo "tempDir: ${tempDir}"
echo "intermediateDir: ${intermediateDir}"


#Check if output exists
alloutputsexist \
"${sortedBam}" \
"${sortedBamIdx}"

#Get aligned BAM file
getFile ${inputBam}

#Load Picard module
${stage} picard/${picardVersion}
${checkStage}

#Run picard, sort BAM file and create index on the fly
java -jar -Xmx3g ${sortSamJar} \
INPUT=${inputBam} \
OUTPUT=${tmpSortedBam} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}


#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode SortBam: ${returnCode}\n\n"

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