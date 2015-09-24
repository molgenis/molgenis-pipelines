#MOLGENIS walltime=23:59:00 mem=6gb ppn=6

#Parameter mapping
#string stage
#string checkStage
#string picardVersion
#string picardJar
#string sortSamJar
#string alignedBam
#string tempDir
#string alignedSortedBam
#string alignedSortedBamIdx
#string tmpDataDir
#string project
#string intermediateDir

#Load Picard module
${stage} ${picardVersion}
${checkStage}

makeTmpDir ${alignedSortedBam}
tmpAlignedSortedBam=${MC_tmpFile}

makeTmpDir ${alignedSortedBamIdx}
tmpAlignedSortedBamIdx=${MC_tmpFile}

#Run picard, sort BAM file and create index on the fly
java -XX:ParallelGCThreads=4 -jar -Xmx3g ${EBROOTPICARD}/${picardJar} ${sortSamJar} \
INPUT=${alignedBam} \
OUTPUT=${tmpAlignedSortedBam} \
SORT_ORDER=coordinate \
CREATE_INDEX=true \
VALIDATION_STRINGENCY=LENIENT \
MAX_RECORDS_IN_RAM=2000000 \
TMP_DIR=${tempDir}

echo -e "\nSortBam finished succesfull. Moving temp files to final.\n\n"
mv ${tmpAlignedSortedBam} ${alignedSortedBam}
mv ${tmpAlignedSortedBamIdx} ${alignedSortedBamIdx}

