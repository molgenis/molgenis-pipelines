#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

#TODO: create protocol to merge ped/map files if needed

getFile ${resultDir}/merged/merged.bed
getFile ${resultDir}/merged/merged.bim
getFile ${resultDir}/merged/merged.fam

mkdir -p ${resultDir}/family_rel

alloutputsexist \
  ${resultDir}/family_rel/merged.kin

${king} -b ${resultDir}/merged/merged.bed --kinship --related --prefix ${resultDir}/family_rel/~merged

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
  mv ${resultDir}/family_rel/~merged.kin ${resultDir}/family_rel/merged.kin

	putFile ${resultDir}/family_rel/merged.kin

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
