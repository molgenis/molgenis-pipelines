#MOLGENIS walltime=00:01:00 mem=1gb
#string projectJobsDir
#string intermediateDir

cd $projectJobsDir

countShScripts=`ls *.sh | wc -l`
countFinishedFiles=`ls *.sh.finished | wc -l`

#remove 2, because this step (CountAllFinishedFiles) is not finished yet and there is submit.sh
countShScripts=$(($countShScripts-2))

rm -f ${projectJobsDir}/${taskId}_INCORRECT

if (( $countShScripts == $countFinishedFiles ))
then	
	echo "all files are finished" > ${projectJobsDir}/${taskId}_CORRECT
else
	
	for getSh in $(ls *.sh)
	do
		if [ ! -f ${getSh}.finished ]
		then
			${getSh}.finished >> ${projectJobsDir}/${taskId}_INCORRECT
		fi
	done
fi
	
chmod -R g+rwX $intermediateDir
