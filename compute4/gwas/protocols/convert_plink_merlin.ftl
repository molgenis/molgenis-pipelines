#MOLGENIS walltime=96:00:00 nodes=1 cores=1 mem=4

#FOREACH project

getFile ${resultDir}/qc_1/merged.ped
getFile ${resultDir}/qc_1/merged.map


alloutputsexist \
  ${resultDir}/qc_1/merged_merlin.ped \
	${resultDir}/qc_1/merged_merlin.map

${python_exec} ${convert_plink_to_merlin} ${resultDir}/qc_1/merged.ped ${resultDir}/qc_1/merged.map ${resultDir}/qc_1/~merged_merlin.ped ${resultDir}/qc_1/~merged_merlin.map

#Get return code from last program call
returnCode=$?

if [ $returnCode -eq 0 ]
then
  mv  ${resultDir}/qc_1/~merged_merlin.ped ${resultDir}/qc_1/merged_merlin.ped
  mv  ${resultDir}/qc_1/~merged_merlin.map ${resultDir}/qc_1/merged_merlin.map

  putFile ${resultDir}/qc_1/merged_merlin.ped
  putFile ${resultDir}/qc_1/merged_merlin.map

else
  
	echo -e "\nNon zero return code not making files final. Existing temp files are kept for debuging purposes\n\n"
	#Return non zero return code
	exit 1

fi
