set -e
set -u

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

groupname=$1

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg


ls -1 ${PROJECTSDIR} > ${LOGDIR}/allProjects.txt

pipeline="dna"

function finish {
	echo "TRAPPED"
	if [ -f ${LOGDIR}/copyProjectDataToPrm.sh.locked ]
	then
		rm ${LOGDIR}/copyProjectDataToPrm.sh.locked
	fi
}
trap finish HUP INT QUIT TERM EXIT ERR

ARR=()
while read i
do
ARR+=($i)
done<${LOGDIR}/allProjects.txt

echo "Logfiles will be written to $LOGDIR"
for line in ${ARR[@]}
do
        projectName=${line}
        LOGGER=${LOGDIR}/${projectName}.copyProjectDataToPrm.logger

        FINISHED="no"

        if [ -f ${LOGDIR}/copyProjectDataToPrm.sh.locked ]
        then
            	exit 0
	else
		touch ${LOGDIR}/copyProjectDataToPrm.sh.locked
        fi
	##command to check if projectfolder exists
	makeProjectDataDir=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "sh ${PROJECTSDIRPRM}/checkProjectData.sh ${PROJECTSDIRPRM} ${projectName}")	
	
	copyProjectDataDiagnosticsClusterToPrm="${PROJECTSDIR}/${projectName}/* ${groupname}-dm@calculon.hpc.rug.nl:${PROJECTSDIRPRM}/${projectName}"
	if [[ -f $LOGDIR/${projectName}/${projectName}.pipeline.finished && ! -f $LOGDIR/${projectName}/${projectName}.projectDataCopiedToPrm ]]
	then
		countFilesProjectDataDirTmp=$(ls -R ${PROJECTSDIR}/${projectName}/*/results/ | wc -l)
		module load hashdeep/4.4-foss-2015b
		if [ ! -f ${PROJECTSDIR}/${projectName}.allResultmd5sums ]
		then
			cd ${PROJECTSDIR}/${projectName}/
			md5deep -r -j0 -o f -l */results/ > ${projectName}.allResultmd5sums
		fi
		
		if [ "${makeProjectDataDir}" == "f" ]
		then
			echo "copying project data from DiagnosticsCluster to prm" >> ${LOGGER}
                        rsync -r -av --exclude rawdata/ ${copyProjectDataDiagnosticsClusterToPrm} >> $LOGGER
			rsync -r -av ${PROJECTSDIR}/${projectName}/${projectName}.allResultmd5sums ${groupname}-dm@calculon.hpc.rug.nl:${PROJECTSDIRPRM}/${projectName}/
			makeProjectDataDir="t"
		fi
		if [ "${makeProjectDataDir}" == "t" ]
                then
                        countFilesProjectDataDirPrm=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "ls -R ${PROJECTSDIRPRM}/${projectName}/*/results/ | wc -l")
                        if [ ${countFilesProjectDataDirTmp} -eq ${countFilesProjectDataDirPrm} ]
                        then
                                COPIEDTOPRM=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "sh ${PROJECTSDIRPRM}/check.sh ${PROJECTSDIRPRM} ${projectName}")
				if [[ "${COPIEDTOPRM}" == *"FAILED"* ]]
                                then
                                        echo "md5sum check failed, the copying will start again" >> ${LOGGER}
                                        rsync -r -av --exclude rawdata/ ${copyProjectDataDiagnosticsClusterToPrm} >> $LOGGER 2>&1
					echo "copy failed" >> $LOGDIR/${projectName}.copyProjectDataToPrm.failed
                                elif [[ "${COPIEDTOPRM}" == *"PASS"* ]]
                                then
                                        touch $LOGDIR/${projectName}.projectDataCopiedToPrm
					echo "finished copying project data to calculon" >> ${LOGGER}
					printf "De project data voor project ${projectName} is gekopieerd naar ${PROJECTSDIRPRM}" | mail -s "project data for project ${projectName} is copied to permanent storage" ${ONTVANGER}

					mv $LOGDIR/${projectName}.projectDataCopiedToPrm $LOGDIR/${projectName}/
					mv $LOGDIR/${projectName}.copyProjectDataToPrm.logger $LOGDIR/${projectName}/

				  	if [ -f $LOGDIR/${projectName}.copyProjectDataToPrm.failed ] 
                                        then
						rm $LOGDIR/${projectName}.copyProjectDataToPrm.failed
					fi
                                fi
                        else
				echo "copying data..." >> $LOGGER
                                rsync -r -av --exclude rawdata/ ${copyProjectDataDiagnosticsClusterToPrm} >> $LOGGER 2>&1
                        fi
                fi
        fi

	if [ -f $LOGDIR/${projectName}.copyProjectDataToPrm.failed ]
	then
		COUNT=$(cat $LOGDIR/${projectName}.copyProjectDataToPrm.failed | wc -l)
		if [ $COUNT == 10  ]
		then
			HOSTNA=$(hostname)
			printf "De md5sum checks voor project ${projectName} op ${PROJECTSDIRPRM} zijn mislukt.De originele data staat op ${HOSTNA}:${PROJECTSDIR}\n\nDeze mail is verstuurd omdat er al 10 pogingen zijn gedaan om de data te kopieren/md5summen" | mail -s "${projectName} failing to copy to permanent storage" ${ONTVANGER}
		fi
	fi
	rm ${LOGDIR}/copyProjectDataToPrm.sh.locked
done

trap - EXIT
exit 0
