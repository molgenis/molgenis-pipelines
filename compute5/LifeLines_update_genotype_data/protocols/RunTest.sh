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
#string chr

#Echo parameter values
echo "resultDir: ${resultDir}"
echo "validationDir: ${validationDir}"
echo "referenceStudyDir: ${referenceStudyDir}"
echo "validatePl: ${validatePl}"
echo "studyId: ${studyId}"
echo "studyMappingFile: ${studyMappingFile}"
echo "validationReport: ${validationReport}"
echo "tmpProjectDir: ${tmpProjectDir}"
echo "chr: ${chr}"


#Run validation script
perl ${validatePl} \
-studyId ${studyId} \
-studyDir ${tmpProjectDir} \
-pseudoFile ${studyMappingFile} \
-testDir ${validationDir} \
-refStudyDir ${referenceStudyDir} \
-report ${validationReport}

#Move *.dose file to tmp directory (*.dose.gz we keep to save diskspace)
mv ${resultDir}/${studyId}_chr${chr}.dose ${tmpProjectDir}/${studyId}_chr${chr}.dose

#Move other results into results directory
echo "Moving BED, BIM, FAM and DOSE.GZ plus accompanying md5sums to results directory"
mv ${tmpProjectDir}/${studyId}_chr${chr}.bed ${resultDir}/${studyId}_chr${chr}.bed
mv ${tmpProjectDir}/${studyId}_chr${chr}.bim ${resultDir}/${studyId}_chr${chr}.bim
mv ${tmpProjectDir}/${studyId}_chr${chr}.fam ${resultDir}/${studyId}_chr${chr}.fam
mv ${tmpProjectDir}/${studyId}_chr${chr}.bed.md5 ${resultDir}/${studyId}_chr${chr}.bed.md5
mv ${tmpProjectDir}/${studyId}_chr${chr}.bim.md5 ${resultDir}/${studyId}_chr${chr}.bim.md5
mv ${tmpProjectDir}/${studyId}_chr${chr}.fam.md5 ${resultDir}/${studyId}_chr${chr}.fam.md5
mv ${tmpProjectDir}/${studyId}_chr${chr}.dose.gz ${resultDir}/${studyId}_chr${chr}.dose.gz
mv ${tmpProjectDir}/${studyId}_chr${chr}.dose.gz ${resultDir}/${studyId}_chr${chr}.dose.gz.md5

