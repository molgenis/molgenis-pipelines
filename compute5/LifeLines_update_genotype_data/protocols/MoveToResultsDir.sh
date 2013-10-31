#MOLGENIS walltime=01:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

#Parameter mapping
#string resultDir
#string tmpProjectDir
#string studyId
#string chr

#Echo parameter values
echo "resultDir: ${resultDir}"
echo "tmpProjectDir: ${tmpProjectDir}"
echo "studyId: ${studyId}"
echo "chr: ${chr}"


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