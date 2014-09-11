#MOLGENIS walltime=23:59:00 mem=3gb

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string samToBamJar
#string alignedSam
#string tempDir
#string intermediateDir
#string alignedBam

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "picardVersion: ${picardVersion}"
echo "samToBamJar: ${samToBamJar}"
echo "alignedSam: ${alignedSam}"
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

makeTmpDir ${alignedSam}
tmpAlignedBam=${MC_tmpFile}

#Run picard, convert SAM to BAM
java -XX:ParallelGCThreads=4 -jar -Xmx3g $PICARD_HOME/${samToBamJar} \
INPUT=${alignedSam} \
OUTPUT=${tmpAlignedBam} \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}

    echo -e "\nSamToBam finished succesfull. Moving temp files to final.\n\n"
    mv ${tmpAlignedBam} ${alignedBam}
    putFile "${alignedBam}"

