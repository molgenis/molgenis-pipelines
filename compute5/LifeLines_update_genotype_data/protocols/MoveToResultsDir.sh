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

if [ -f ${tmpProjectDir}/${studyId}_chr${chr}.bed ]
then
        #Move other results into results directory
        echo "Moving BED, BIM, FAM and DOSE.GZ plus accompanying md5sums to results directory"
	gzip ${tmpProjectDir}/${studyId}_chr${chr}.bed.gz
        echo "compressed bed file"
        mv ${tmpProjectDir}/${studyId}_chr${chr}.bed.gz ${resultDir}/${studyId}_chr${chr}.bed.gz
	gzip ${tmpProjectDir}/${studyId}_chr${chr}.bim
        echo "compressed bim file"
        mv ${tmpProjectDir}/${studyId}_chr${chr}.bim.gz ${resultDir}/${studyId}_chr${chr}.bim.gz
        gzip ${tmpProjectDir}/${studyId}_chr${chr}.fam   
        echo "compressed fam file"
        mv ${tmpProjectDir}/${studyId}_chr${chr}.fam.gz ${resultDir}/${studyId}_chr${chr}.fam.gz
        mv ${tmpProjectDir}/${studyId}_chr${chr}.bed.md5 ${resultDir}/${studyId}_chr${chr}.bed.md5
        mv ${tmpProjectDir}/${studyId}_chr${chr}.bim.md5 ${resultDir}/${studyId}_chr${chr}.bim.md5
        mv ${tmpProjectDir}/${studyId}_chr${chr}.fam.md5 ${resultDir}/${studyId}_chr${chr}.fam.md5
        mv ${tmpProjectDir}/${studyId}_chr${chr}.dose.gz ${resultDir}/${studyId}_chr${chr}.dose.gz
        mv ${tmpProjectDir}/${studyId}_chr${chr}.dose.gz.md5 ${resultDir}/${studyId}_chr${chr}.dose.gz.md5
else
	rm ${resultDir}/${studyId}_chr${chr}.dose.gz
        rm ${resultDir}/${studyId}_chr${chr}.dose.gz.md5
        echo "The snpsubset is empty, nothing to be moved! Removed dose.gz and dose.gz.md5 to not make it to confusing for the researchers"
fi
