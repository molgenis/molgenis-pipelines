#MOLGENIS walltime=23:59:00 mem=6gb ppn=4

#Parameter mapping
#string tmpName
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
#string tmpDataDir
#string project
#string logsDir
#string seqType

#Load Pindel module
${stage} pindel/024t
${stage} vcftools/0.1.12a
${checkStage}

makeTmpDir ${pindelOutput}
tmpPindelOutput=${MC_tmpFile}

#make symlink of .bai file to .bam.bai extension (needed for Pindel)
if [ ! -L ${bamFilePindel}.bai ];
	then
	ln -s ${bamFilePindelIdx} ${bamFilePindel}.bai
fi

configFile=${intermediateDir}/${externalSampleID}.pindel.config.txt


echo "${bamFilePindel} ${targetedInsertSize} ${externalSampleID}" > ${configFile}
if [ "${seqType}" == "PE" ]
then
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
	-v ${pindelOutputVcf}.tmp

#remove variants where StartPosition is > then EndPosition
perl /gcc/tools/scripts/filterPindelVcf.pl ${pindelOutputVcf}.tmp ${pindelOutputVcf}


elif [ "${seqType}" == "SR" ] 
then
	echo "Pindel step is skipped because it is not Paired End but the seqType="${seqType}
fi

