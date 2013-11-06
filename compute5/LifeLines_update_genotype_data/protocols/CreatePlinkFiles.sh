#MOLGENIS walltime=50:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

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
#string doseFile
#string referenceStudyDir

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
echo "doseFile: ${doseFile}"
echo "referenceStudyDir: ${referenceStudyDir}"


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
--out ${tmpProjectDir}/~${studyId}_chr${chr}

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode Plink Binary: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then
	echo -e "\nPlink Binary finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.bed ${tmpProjectDir}/${studyId}_chr${chr}.bed
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.bim ${tmpProjectDir}/${studyId}_chr${chr}.bim
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.fam ${tmpProjectDir}/${studyId}_chr${chr}.fam
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.nosex ${tmpProjectDir}/${studyId}_chr${chr}.nosex
	mv ${tmpProjectDir}/~${studyId}_chr${chr}.log ${tmpProjectDir}/${studyId}_chr${chr}.log
	
	echo -e "\nGenerating md5sums.\n\n"
	cd ${tmpProjectDir}/
	
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.bed > ${tmpProjectDir}/${studyId}_chr${chr}.bed.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.bim > ${tmpProjectDir}/${studyId}_chr${chr}.bim.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.fam > ${tmpProjectDir}/${studyId}_chr${chr}.fam.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.nosex > ${tmpProjectDir}/${studyId}_chr${chr}.nosex.md5
	md5sum ${tmpProjectDir}/${studyId}_chr${chr}.log > ${tmpProjectDir}/${studyId}_chr${chr}.log.md5
	
	if [[ "${referenceStudyDir}" == *UnimputedPedMap* ]]
	then
		echo -e "\nDetected UnimputedPedMap in path of referenceStudyDir, meaning this is raw data. Moving BIM, BED and FAM file to results directory.\n";
		mv ${tmpProjectDir}/${studyId}_chr${chr}.bed ${resultDir}/${studyId}_chr${chr}.bed
		mv ${tmpProjectDir}/${studyId}_chr${chr}.bim ${resultDir}/${studyId}_chr${chr}.bim
		mv ${tmpProjectDir}/${studyId}_chr${chr}.fam ${resultDir}/${studyId}_chr${chr}.fam
		mv ${tmpProjectDir}/${studyId}_chr${chr}.bed.md5 ${resultDir}/${studyId}_chr${chr}.bed.md5
		mv ${tmpProjectDir}/${studyId}_chr${chr}.bim.md5 ${resultDir}/${studyId}_chr${chr}.bim.md5
		mv ${tmpProjectDir}/${studyId}_chr${chr}.fam.md5 ${resultDir}/${studyId}_chr${chr}.fam.md5
		
		putFile "${resultDir}/${studyId}_chr${chr}.bed"
		putFile "${resultDir}/${studyId}_chr${chr}.bim"
		putFile "${resultDir}/${studyId}_chr${chr}.fam"
		putFile "${resultDir}/${studyId}_chr${chr}.bed.md5"
		putFile "${resultDir}/${studyId}_chr${chr}.bim.md5"
		putFile "${resultDir}/${studyId}_chr${chr}.fam.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.log"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.log.md5"
	else
	
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.bed"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.bim"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.fam"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.log"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.bed.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.bim.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.fam.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.nosex.md5"
		putFile "${tmpProjectDir}/${studyId}_chr${chr}.log.md5"
	fi
else
	echo -e "\nFailed to move Plink Binary results to ${intermediateDir}\n\n"
	exit -1
fi
