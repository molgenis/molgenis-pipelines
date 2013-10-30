#MOLGENIS walltime=30:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

#Parameter mapping
#string resultDir
#string validationDir
#string referenceStudyDir
#string validatePl
#string studyId
#string studyMappingFile
#string validationReport
#string tmpProjectDir

#Echo parameter values
echo "resultDir: ${resultDir}"
echo "validationDir: ${validationDir}"
echo "referenceStudyDir: ${referenceStudyDir}"
echo "validatePl: ${validatePl}"
echo "studyId: ${studyId}"
echo "studyMappingFile: ${studyMappingFile}"
echo "validationReport: ${validationReport}"
echo "tmpProjectDir: ${tmpProjectDir}"


#Run validation script
perl ${validatePl} \
-studyId ${studyId} \
-studyDir ${tmpProjectDir} \
-pseudoFile ${studyMappingFile} \
-testDir ${validationDir} \
-refStudyDir ${referenceStudyDir} \
-report ${validationReport}
