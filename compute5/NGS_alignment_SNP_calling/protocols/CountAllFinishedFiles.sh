#MOLGENIS walltime=00:01:00 mem=1gb
#string projectJobsDir

cd $projectJobsDir

countShScripts=`ls *.sh | wc -l`
countFinishedFiles=`ls *.finished | wc -l`

#remove 1, because this step is not finished yet
countShScripts=$(($countShScripts-1))

rm ${projectJobsDir}/${taskId}_INCORRECT

if (( $countShScripts == $finishedFiles ))
then	
	echo "all files are finished" > ${projectJobsDir}/${taskId}_CORRECT
else
	
	for getSh in $(ls *.sh)
	do
		ls ${getSh}.finished >> ${projectJobsDir}/${taskId}_INCORRECT

	done
fi
	
