#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

touch ${resultDir}/prunning/allfiles.txt

getFile ${resultDir}/prunning/chr1.ped
getFile ${resultDir}/prunning/chr1.map

for $CHROMOSOME in {2..22}
do
   getFile ${resultDir}/prunning/chr$CHROMOSOME.ped
   getFile ${resultDir}/prunning/chr$CHROMOSOME.map
   echo "${resultDir}/prunning/chr$CHROMOSOME.ped ${resultDir}/prunning/chr$CHROMOSOME.map" >> ${resultDir}/prunning/allfiles.txt
done

alloutputsexist \
   ${resultDir}/prunning/merged.ped \
   ${resultDir}/prunning/merged.map

${plink} --file ${resultDir}/prunning/chr1 --merge-list ${resultDir}/prunning/allfiles.txt --noweb --recode --out ${resultDir}/prunning/~merged

${plink} --file ${resultDir}/prunning/chr1 --merge-list ${resultDir}/prunning/allfiles.txt --noweb --make-bed --out ${resultDir}/prunning/~merged


#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
    mv ${resultDir}/prunning/~merged.ped ${resultDir}/prunning/merged.ped
    mv ${resultDir}/prunning/~merged.map ${resultDir}/prunning/merged.map

    mv ${resultDir}/prunning/~merged.fam ${resultDir}/prunning/merged.fam
    mv ${resultDir}/prunning/~merged.bim ${resultDir}/prunning/merged.bim
    mv ${resultDir}/prunning/~merged.bed ${resultDir}/prunning/merged.bed

    putFile ${resultDir}/prunning/merged.ped
    putFile ${resultDir}/prunning/merged.map
    putFile ${resultDir}/prunning/merged.fam
    putFile ${resultDir}/prunning/merged.bim
    putFile ${resultDir}/prunning/merged.bed

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
