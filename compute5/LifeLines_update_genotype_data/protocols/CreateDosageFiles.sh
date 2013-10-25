#MOLGENIS walltime=24:00:00 nodes=1 ppn=1 mem=4gb queue=gaf

#Parameter mapping
#string studyDir
#string convertDosePy
#string convertDoseGonlPy
#string studyId
#string doseFile
#string chr
#string resultDir
#string tmpUpdateIds
#string tmpProjectDir

#Echo parameter values
echo "studyDir: ${studyDir}"
echo "convertDosePy: ${convertDosePy}"
echo "convertDoseGonlPy: ${convertDoseGonlPy}"
echo "studyId: ${studyId}"
echo "doseFile: ${doseFile}"
echo "chr: ${chr}"
echo "resultDir: ${resultDir}"
echo "tmpUpdateIds: ${tmpUpdateIds}"
echo "tmpProjectDir: ${tmpProjectDir}"

#Check doseFile parameter to establish which dosage conversion script to use
if [[ "${doseFile}" == *MINIMAC* || "${doseFile}" == *minimac* || "${doseFile}" == *Minimac* || "${doseFile}" == *MiniMac* ]]
then
	echo -e "\nDetected Minimac in path of doseFile. Using ${convertDoseGonlPy} for conversion.\n";
	CONVERTDOSEPY="${convertDoseGonlPy}"
else
	echo -e "\nUsing ${convertDosePy} for conversion.\n"
	CONVERTDOSEPY="${convertDosePy}"
fi


#Convert dosage files
python $CONVERTDOSEPY \
--subsetFile ${tmpUpdateIds} \
--doseFile ${doseFile} \
--outFile ${resultDir}/${studyId}_chr${chr}.dose

gzip ${resultDir}/${studyId}_chr${chr}.dose -c > ${resultDir}/~${studyId}_chr${chr}.dose.gz

#Get return code from last program call
returnCode=$?

echo -e "\nreturnCode convertDosage.py: ${returnCode}\n\n"

if [ $returnCode -eq 0 ]
then
	echo -e "\nconvertDosage.py finished succesfull. Moving temp files to final.\n\n"
	mv ${resultDir}/~${studyId}_chr${chr}.dose.gz ${resultDir}/${studyId}_chr${chr}.dose.gz
	
	echo -e "\nGenerating md5sums.\n\n"
	cd ${resultDir}/
	
	md5sum ${resultDir}/${studyId}_chr${chr}.dose.gz > ${resultDir}/${studyId}_chr${chr}.dose.gz.md5
	
	putFile "${resultDir}/${studyId}_chr${chr}.dose.gz"
	putFile "${resultDir}/${studyId}_chr${chr}.dose.gz.md5"
else
	echo -e "\nFailed to move convertDosage.py results to ${intermediateDir}\n\n"
	exit -1
fi