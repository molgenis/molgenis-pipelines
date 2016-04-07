#MOLGENIS walltime=23:59:00 mem=5gb ppn=10

#Parameter mapping
#string tmpName
#string stage
#string checkStage
#string sambambaVersion
#string sambambaTool
#string alignedBam
#string alignedSortedBam
#string tmpDataDir
#string project
#string logsDir
#string tempDir

#Load Picard module
${stage} ${sambambaVersion}
${checkStage}

makeTmpDir ${alignedSortedBam}
tmpAlignedSortedBam=${MC_tmpFile}

${EBROOTSAMBAMBA}/${sambambaTool} sort \
--tmpdir=${tempDir} \
-t 10 \
-m 4GB \
-o ${tmpAlignedSortedBam} \
${alignedBam}

echo -e "\nSambambaSort finished succesfull. Moving temp files to final.\n\n"
mv ${tmpAlignedSortedBam} ${alignedSortedBam}
echo "mv ${tmpAlignedSortedBam} ${alignedSortedBam}"




