#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

touch ${resultDir}/qc_1/allfiles.txt

getFile ${resultDir}/qc_1/chr1.ped
getFile ${resultDir}/qc_1/chr1.map

for $CHROMOSOME in {2..22}
do
   getFile ${resultDir}/qc_1/chr$CHROMOSOME.ped
   getFile ${resultDir}/qc_1/chr$CHROMOSOME.map
   echo "${resultDir}/qc_1/chr$CHROMOSOME.ped ${resultDir}/qc_1/chr$CHROMOSOME.map" >> ${resultDir}/qc_1/allfiles.txt
done

alloutputsexist \
   ${resultDir}/qc_1/merged.ped \
   ${resultDir}/qc_1/merged.map

${plink} --file ${resultDir}/qc_1/chr1 --merge-list ${resultDir}/qc_1/allfiles.txt --noweb --recode --out ${resultDir}/qc_1/~merged

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${resultDir}/qc_1/~merged.ped ${resultDir}/qc_1/merged.ped
    mv ${resultDir}/qc_1/~merged.map ${resultDir}/qc_1/merged.map

    putFile ${resultDir}/qc_1/merged.ped
    putFile ${resultDir}/qc_1/merged.map

else
  
  echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
