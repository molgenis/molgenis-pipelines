#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

mkdir -p ${resultDir}
rm -f ${resultDir}/allfiles.txt

getFile ${studyInputDir}/chr1.ped
getFile ${studyInputDir}/chr1.map

for CHROMOSOME in {2..22}
do
   getFile ${studyInputDir}/chr$CHROMOSOME.ped
   getFile ${studyInputDir}/chr$CHROMOSOME.map
   echo "${studyInputDir}/chr$CHROMOSOME.ped ${studyInputDir}/chr$CHROMOSOME.map" >> ${resultDir}/allfiles.txt
done

alloutputsexist \
   ${resultDir}/merged.ped \
   ${resultDir}/merged.map

${plink} --file ${studyInputDir}/chr1 --merge-list ${resultDir}/allfiles.txt --noweb --recode --out ${resultDir}/~merged

${plink} --file ${studyInputDir}/chr1 --merge-list ${resultDir}/allfiles.txt --noweb --make-bed --out ${resultDir}/~merged


#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${resultDir}/~merged.ped ${resultDir}/merged.ped
    mv ${resultDir}/~merged.map ${resultDir}/merged.map

    mv ${resultDir}/~merged.fam ${resultDir}/merged.fam
    mv ${resultDir}/~merged.bim ${resultDir}/merged.bim
    mv ${resultDir}/~merged.bed ${resultDir}/merged.bed

    putFile ${resultDir}/merged.ped
    putFile ${resultDir}/merged.map
    putFile ${resultDir}/merged.fam
    putFile ${resultDir}/merged.bim
    putFile ${resultDir}/merged.bed

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
