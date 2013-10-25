#MOLGENIS walltime=30:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

#Parameter mapping
#string studyDir
#string plinkBin
#string imputedStudy
#string studyId
#string chr
#string tmpUpdateIds
#string resultDir
#string tmpKeep
#string tmpProjectDir

#Echo parameter values
echo "studyDir: ${studyDir}"
echo "plinkBin: ${plinkBin}"
echo "imputedStudy: ${imputedStudy}"
echo "studyId: ${studyId}"
echo "chr: ${chr}"
echo "tmpUpdateIds: ${tmpUpdateIds}"
echo "resultDir: ${resultDir}"
echo "tmpKeep: ${tmpKeep}"
echo "tmpProjectDir: ${tmpProjectDir}"


##CAN'T WE COMBINE BOTH STEPS INTO A SINGLE PLINK COMMAND??

#Filter and updateIds imputedStudy data
${plinkBin} \
--noweb \
--file ${imputedStudy} \
--update-ids ${tmpUpdateIds} \
--out ${tmpProjectDir}/~${studyId}_chr${chr} \
--keep ${tmpKeep} \
--recode

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode Plink: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then
	echo -e "\nPlink finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.ped ${tmpProjectDir}/${studyId}_chr${chr}.ped
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.map ${tmpProjectDir}/${studyId}_chr${chr}.map
	
	echo -e "\nGenerating md5sums.\n\n"
	cd ${resultDir}/
	
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.ped > ${tmpProjectDir}/${studyId}_chr${chr}.ped.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.map > ${tmpProjectDir}/${studyId}_chr${chr}.map.md5
	
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.ped"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.map"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.ped.md5"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.map.md5"
else
	echo -e "\nFailed to move Plink results to ${intermediateDir}\n\n"
	exit -1
fi


#Generate bim/bed/fam
${plinkBin} \
--noweb \
--file ${tmpProjectDir}/${studyId}_chr${chr} \
--make-bed \
--out ${resultDir}/~${studyId}_chr${chr}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode Plink Binary: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then
	echo -e "\nPlink Binary finished succesfull. Moving temp files to final.\n\n"
	mv ${resultDir}/~${studyId}_chr${chr}.bed ${resultDir}/${studyId}_chr${chr}.bed
	mv ${resultDir}/~${studyId}_chr${chr}.bim ${resultDir}/${studyId}_chr${chr}.bim
	mv ${resultDir}/~${studyId}_chr${chr}.fam ${resultDir}/${studyId}_chr${chr}.fam
	mv ${resultDir}/~${studyId}_chr${chr}.nosex ${tmpProjectDir}/${studyId}_chr${chr}.nosex
	mv ${resultDir}/~${studyId}_chr${chr}.log ${tmpProjectDir}/${studyId}_chr${chr}.log
	
	echo -e "\nGenerating md5sums.\n\n"
	cd ${resultDir}/
	
	md5sum ${resultDir}/${studyId}_chr${chr}.bed > ${resultDir}/${studyId}_chr${chr}.bed.md5
	md5sum ${resultDir}/${studyId}_chr${chr}.bim > ${resultDir}/${studyId}_chr${chr}.bim.md5
	md5sum ${resultDir}/${studyId}_chr${chr}.fam > ${resultDir}/${studyId}_chr${chr}.fam.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.nosex > ${tmpProjectDir}/${studyId}_chr${chr}.nosex.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.log > ${tmpProjectDir}/${studyId}_chr${chr}.log.md5
	
	putFile "${resultDir}/${studyId}_chr${chr}.bed"
	putFile "${resultDir}/${studyId}_chr${chr}.bim"
	putFile "${resultDir}/${studyId}_chr${chr}.fam"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.log"
	putFile "${resultDir}/${studyId}_chr${chr}.bed.md5"
	putFile "${resultDir}/${studyId}_chr${chr}.bim.md5"
	putFile "${resultDir}/${studyId}_chr${chr}.fam.md5"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex.md5"
	putFile "${tmpProjectDir}/${studyId}_chr${chr}.log.md5"
else
	echo -e "\nFailed to move Plink Binary results to ${intermediateDir}\n\n"
	exit -1
fi
