#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

#Parameter mapping
#string stage
#string checkStage
#string bamFilePindel
#string tempDir
#string intermediateDir
#string indexFile
#string targetedInsertSize
#string bamFilePindelIdx
#string indexFileID
#string pindelOutput
#string pindelOutputVcf
#list externalSampleID

#Load Pindel module
${stage} pindel/0.2.5a3
${checkStage}

#Check if output exists
alloutputsexist \
"${pindelOutputVcf}"\

#Echo parameter values
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "bamFilePindel: ${bamFilePindel}"
echo "targetedInsertSize: ${targetedInsertSize}"
echo "indexFile: ${indexFile}"
echo "intermediateDir: ${intermediateDir}"
echo "bamFilePindelIdx: ${bamFilePindelIdx}"
echo "indexFileID: ${indexFileID}"
echo "pindelOutputVcf: ${pindelOutputVcf}"

makeTmpDir ${pindelOutput}
tmpPindelOutput=${MC_tmpFile}

#make symlink of .bai file to .bam.bai extension (needed for Pindel)
if [ ! -L ${bamFilePindel}.bai ];
	then
	ln -s ${bamFilePindelIdx} ${bamFilePindel}.bai
fi

configFile=${intermediateDir}/${externalSampleID}.pindel.config.txt

echo "${bamFilePindel} ${targetedInsertSize} ${externalSampleID}" > ${configFile}

pindel \
-f ${indexFile} \
-T 4 \
-i ${configFile} \
-o ${tmpPindelOutput}

#Cat outputs together. Pindel produces more output for other sorts of SVs,
#these can't be converted to VCF yet, so are not merged.
cat \
${tmpPindelOutput}_D \
${tmpPindelOutput}_LI \
${tmpPindelOutput}_SI \
> ${tmpPindelOutput}_MERGED

echo "MC_tmpFolder: ${MC_tmpFolder}*"

mv ${MC_tmpFolder}* ${intermediateDir}

#Get current date
DATE=`date | awk '{print $6,$2,$3}' OFS="_"`

#Convert pindel output to VCF and use GATK annotation as output
pindel2vcf \
-p ${pindelOutput}_MERGED \
-r ${indexFile} \
-R ${indexFileID} \
-d $DATE \
--gatk_compatible \
-v ${pindelOutputVcf}
