set -e
set -u

groupname=$1
MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

ALLFINISHED=()
if ls ${LOGDIR}/*.pipeline.finished 1> /dev/null 2>&1 
then
	ls ${LOGDIR}/*.pipeline.finished > ${LOGDIR}/AllProjects.pipeline.finished.csv
else
	exit 0
fi
while read line 
do
	ALLFINISHED+=("${line} ")
done<${LOGDIR}/AllProjects.pipeline.finished.csv


for i in ${ALLFINISHED[@]}
do
	filename=$(basename $i)
	projectName="${filename%%.*}"

	## Check which rawdata belongs to the project
	for i in $(ls ${PROJECTSDIR}/${projectName}/*/rawdata/ngs/*.md5)
 	do 
		if [ -L $i ]
		then 
			readlink $i > ${LOGDIR}/${projectName}/${projectName}.rawdatalink 
		fi
	done
	## if md5sums for are not present try to fix it via the fq.gz
	if [ ! -f  ${LOGDIR}/${projectName}/${projectName}.rawdatalink ]
        then
                for i in $(ls ${PROJECTSDIR}/${projectName}/*/rawdata/ngs/*.fq.gz)
                do
                        if [ -L $i ]
                        then
                                readlink $i > ${LOGDIR}/${projectName}/${projectName}.rawdatalink

                        fi
                done
        fi

	rawdataName=""
        if [  -f  ${LOGDIR}/${projectName}/${projectName}.rawdatalink ]
        then
		while read line 
		do 
			dirname $line > ${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName 
		done<${LOGDIR}/${projectName}/${projectName}.rawdatalink

		rawDataName=$(while read line ; do basename $line ; done<${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName)
	fi

	echo "moving ${projectName} files to ${LOGDIR}/${projectName}/ and removing tmp finished files"
	if [[ -f ${LOGDIR}/${projectName}/${projectName}.pipeline.logger  && -f ${LOGDIR}/${projectName}/${projectName}.pipeline.started ]]
	then 
		if [[ -f ${LOGDIR}/${projectName}/${projectName}.rawdatalink && -f ${LOGDIR}/${projectName}/${projectName}.rawdatalinkDirName ]]
		then
			touch ${LOGDIR}/${projectName}/${rawDataName}
		fi
	
		mv ${LOGDIR}/${projectName}.pipeline.finished ${LOGDIR}/${projectName}/

	else
		echo "there is/are missing some files:${projectName}.pipeline.logger or  ${projectName}.pipeline.started"
		echo "there is/are missing some files:${projectName}.pipeline.logger or  ${projectName}.pipeline.started" >> ${LOGDIR}/${projectName}/${projectName}.pipeline.logger
	fi
	if [ ! -f ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed ]
        then
            	mailTo="helpdesk.gcc.groningen@gmail.com"
                if [ $groupname == "umcg-gaf" ]
                then
                    	mailTo="helpdesk.gcc.groningen@gmail.com"
                elif [ "${groupname}" == "umcg-gd" ]
                then
                    	if [ -f /groups/umcg-gd/${tmpDirectory}/logs/mailinglistDiagnostiek.txt ]
                        then
                            	mailTo=$(cat /groups/umcg-gd/${tmpDirectory}/logs/mailinglistDiagnostiek.txt)
                        else
                            	echo "mailingListDiagnostiek.txt bestaat niet!!"
                                exit 0
                        fi
                fi
                printf "The results can be found: ${PROJECTSDIR}/${projectName} \n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${projectName} on `date +%d/%m/%Y` `date +%H:%M`" ${mailTo}
                touch ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed

        fi

done

