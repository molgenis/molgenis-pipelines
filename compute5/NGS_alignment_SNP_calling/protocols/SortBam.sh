#MOLGENIS walltime=23:59:00 mem=3gb ppn=4

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string sortSamJar
#string inputSortBam
#string tempDir
#string sortedBam
#string sortedBamIdx

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "sortSamJar: ${sortSamJar}"
echo "inputSortBam: ${inputSortBam}"
echo "sortedBam: ${sortedBam}"
echo "sortedBamIdx: ${sortedBamIdx}"
echo "tempDir: ${tempDir}"

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

makeTmpDir ${sortedBam}
tmpSortedBam=${MC_tmpFile}

makeTmpDir ${sortedBamIdx}
tmpSortedBamIdx=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx3g $PICARD_HOME/${sortSamJar} \
INPUT=${inputSortBam} \
OUTPUT=${tmpSortedBam} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}

    echo -e "\nSortBam finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpSortedBam} ${sortedBam}
    mv ${tmpSortedBamIdx} ${sortedBamIdx}
    putFile "${sortedBam}"
    putFile "${sortedBamIdx}"
