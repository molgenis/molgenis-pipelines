#MOLGENIS walltime=01:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

#Parameter mapping
#string resultDir
#string tmpProjectDir
#string jobDir
#string studyDir
#string studyId
#string studyMappingFile
#string tmpUpdateIds
#string tmpKeep
#string convertBatchesPl
#string beagleBatchFile
#string studyImputationBatches
#string convertPcaPy
#string pcaFile
#string outputStudyPcaFile
#string beagleQualityScoreFile
#string studyImputationQuals
#string validationDir
#string referenceStudyDir

#Echo parameter values
echo "resultDir: ${resultDir}"
echo "tmpProjectDir: ${tmpProjectDir}"
echo "jobDir: ${jobDir}"
echo "studyDir: ${studyDir}"
echo "studyId: ${studyId}"
echo "studyMappingFile: ${studyMappingFile}"
echo "tmpUpdateIds: ${tmpUpdateIds}"
echo "tmpKeep: ${tmpKeep}"
echo "convertBatchesPl: ${convertBatchesPl}"
echo "beagleBatchFile: ${beagleBatchFile}"
echo "studyImputationBatches: ${studyImputationBatches}"
echo "convertPcaPy: ${convertPcaPy}"
echo "pcaFile: ${pcaFile}"
echo "outputStudyPcaFile: ${outputStudyPcaFile}"
echo "beagleQualityScoreFile: ${beagleQualityScoreFile}"
echo "studyImputationQuals: ${studyImputationQuals}"
echo "validationDir: ${validationDir}"
echo "referenceStudyDir: ${referenceStudyDir}"


#Generate output directories
mkdir -p ${studyDir}
mkdir -p ${resultDir}
mkdir -p ${tmpProjectDir}
mkdir -p ${jobDir}
mkdir -p ${validationDir}

#Create updateId and keep files
gawk '{OFS="\t"; print 1,$1,1,$2}' ${studyMappingFile} > ${tmpUpdateIds}
gawk '{OFS="\t"; print 1,$2}' ${studyMappingFile} > ${tmpKeep}

	#Convert PCA file
	python ${convertPcaPy} -s ${tmpUpdateIds} -d ${pcaFile} -o ${outputStudyPcaFile}
	md5sum ${outputStudyPcaFile} > ${outputStudyPcaFile}.md5

	if [ -s "${outputStudyPcaFile}.missing" ]
	then
		#*.missing file is larger than 0, so it contains an ID of a missing sample. Abort the conversion.
		echo -e "\n${outputStudyPcaFile}.missing has a size larger than 0, which means an ID is missing.\n"
		echo -e "Please contact the research office!\n"
	    exit -1
	else
		#No missing sample IDs, continue conversion and move *.missing file to tmp directory
		echo -e "\n${outputStudyPcaFile}.missing has a size of 0, no missing sample IDs found."
		mv ${outputStudyPcaFile}.missing ${tmpProjectDir}/${studyId}_PCA.txt.missing
	fi

#Check referenceStudyDir parameter to establish which dosage conversion script to use
if [[ "${referenceStudyDir}" == *BEAGLE* || "${referenceStudyDir}" == *beagle* || "${referenceStudyDir}" == *Beagle* ]]
then
	echo -e "\nDetected Beagle in path of referenceStudyDir. Converting Beagle batches file and copying Beagle Quality Scores to result directory.\n";
	#Convert batches file
	perl ${convertBatchesPl} ${tmpUpdateIds} ${beagleBatchFile} >> ${studyImputationBatches}
	md5sum ${studyImputationBatches} > ${studyImputationBatches}.md5
	#Copy qualities file
	cp ${beagleQualityScoreFile} ${studyImputationQuals}
	md5sum ${studyImputationQuals} > ${studyImputationQuals}.md5
fi
