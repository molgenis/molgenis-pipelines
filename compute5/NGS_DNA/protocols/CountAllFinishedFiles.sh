#MOLGENIS walltime=00:01:00 mem=1gb
#string tmpName
#string projectJobsDir
#string intermediateDir
#string project
#string logsDir

cd $projectJobsDir


countShScripts=$(find *.sh ! -name '*Delly*.sh'  | wc -l)
countFinishedFiles=$(find *.sh.finished ! -name '*Delly*.sh.finished' | wc -l)

#remove 3, because this step (CountAllFinishedFiles) and the CopyToResultsDir are not finished yet and there is submit.sh
countShScripts=$(($countShScripts-3))

rm -f ${projectJobsDir}/${taskId}_INCORRECT

if [ ${countShScripts} -eq $countFinishedFiles ]
then	
	echo "all files are finished" > ${projectJobsDir}/${taskId}_CORRECT
else
	echo "These files are not finished: " > ${projectJobsDir}/${taskId}_INCORRECT
	for getSh in $(ls *.sh)
	do
		if [ ! -f ${getSh}.finished ]
		then
			echo ${getSh} >> ${projectJobsDir}/${taskId}_INCORRECT
		fi
	done
	exit 0
fi
	

