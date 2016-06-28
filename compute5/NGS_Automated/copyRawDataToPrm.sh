set -e
set -u

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

groupname=$1

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

### VERVANG DOOR UMCG-ATEAMBOT USER
ls ${SAMPLESHEETSDIR}/*.csv > ${SAMPLESHEETSDIR}/allSampleSheets_Zinc.txt
pipeline="dna"

function finish {
	echo "TRAPPED"
	if [ -f ${LOGDIR}/copyDataToPrm.sh.locked ]
	then
		rm ${LOGDIR}/copyDataToPrm.sh.locked
	fi
}
trap finish HUP INT QUIT TERM EXIT ERR

ARR=()
while read i
do
ARR+=($i)
done<${SAMPLESHEETSDIR}/allSampleSheets_Zinc.txt

echo "Logfiles will be written to $LOGDIR"
for line in ${ARR[@]}
do
        csvFile=$(basename $line)
        filePrefix="${csvFile%.*}"
        LOGGER=${LOGDIR}/${filePrefix}.copyToPrm.logger

        FINISHED="no"
        OLDIFS=$IFS
        IFS=_
        set $filePrefix
        sequencer=$2
        run=$3
        IFS=$OLDIFS

        if [ -f ${LOGDIR}/copyDataToPrm.sh.locked ]
        then
		echo "copyToPrm is locked"
            	exit 0
	else
		touch ${LOGDIR}/copyDataToPrm.sh.locked
        fi

	copyRawZincToPrm="${RAWDATADIR}/${filePrefix}/* ${groupname}-dm@calculon.hpc.rug.nl:${RAWDATADIRPRM}/${filePrefix}"
	makeRawDataDir=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "sh ${RAWDATADIRPRM}/../checkRawData.sh ${RAWDATADIRPRM} ${filePrefix}")

	if [[ -f $LOGDIR/${filePrefix}.dataCopiedToZinc && ! -f $LOGDIR/${filePrefix}.dataCopiedToPrm ]]
	then
		countFilesRawDataDirTmp=$(ls ${RAWDATADIR}/${filePrefix}/${filePrefix}* | wc -l)
		if [ "${makeRawDataDir}" == "f" ]
		then
			echo "copying data from zinc to prm" >> ${LOGGER}
                        rsync -r -av ${copyRawZincToPrm} >> $LOGGER
			makeRawDataDir="t"
		fi
		if [ "${makeRawDataDir}" == "t" ]
                then
                        countFilesRawDataDirPrm=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "ls ${RAWDATADIRPRM}/${filePrefix}/${filePrefix}* | wc -l")
                        if [ ${countFilesRawDataDirTmp} -eq ${countFilesRawDataDirPrm} ]
                        then
                                COPIEDTOPRM=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "sh ${RAWDATADIRPRM}/../check.sh ${RAWDATADIRPRM} ${filePrefix}")
				if [[ "${COPIEDTOPRM}" == *"FAILED"* ]]
                                then
                                        echo "md5sum check failed, the copying will start again" >> ${LOGGER}
                                        rsync -r -av ${copyRawZincToPrm} >> $LOGGER 2>&1
					echo "copy failed" >> $LOGDIR/${filePrefix}.failed
                                elif [[ "${COPIEDTOPRM}" == *"PASS"* ]]
                                then
                                        touch $LOGDIR/${filePrefix}.dataCopiedToPrm
					scp ${SAMPLESHEETSDIR}/${csvFile} ${groupname}-dm@calculon.hpc.rug.nl:${RAWDATADIRPRM}/${filePrefix}/
					scp ${SAMPLESHEETSDIR}/${csvFile} ${groupname}-dm@calculon.hpc.rug.nl:${SAMPLESHEETSPRMDIR}
					echo "finished copying data to calculon" >> ${LOGGER}
					logFileStatistics=$(cat ${RAWDATADIR}/${filePrefix}/${filePrefix}*.log)
					if [ ${groupname} == "umcg-gaf" ]
					then
					
						echo -e "Demultiplex statistics ${filePrefix}: \n\n ${logFileStatistics}" | mail -s "Demultiplex statistics ${filePrefix}" ${GAFmail}
					fi
					echo -e "De data voor project ${filePrefix} is gekopieerd naar ${RAWDATADIRPRM}" | mail -s "${filePrefix} copied to permanent storage" ${ONTVANGER}

				  	if [ -f $LOGDIR/${filePrefix}.failed ] 
                                        then
						rm $LOGDIR/${filePrefix}.failed
					fi
                                fi
                        else
				echo "copying data..." >> $LOGGER
                                rsync -r -av ${copyRawZincToPrm} >> $LOGGER 2>&1
                        fi
                fi
        fi

	if [ -f $LOGDIR/${filePrefix}.failed ]
	then
		COUNT=$(cat $LOGDIR/${filePrefix}.failed | wc -l)
		if [ $COUNT == 10  ]
		then
			HOSTNA=$(hostname)
			echo -e "De md5sum checks voor project ${filePrefix} op ${RAWDATADIRPRM} zijn mislukt.De originele data staat op ${HOSTNA}:${RAWDATADIR}\n\nDeze mail is verstuurd omdat er al 10 pogingen zijn gedaan om de data te kopieren/md5summen" | mail -s "${filePrefix} failing to copy to permanent storage" ${ONTVANGER}
		fi
	fi
	rm ${LOGDIR}/copyDataToPrm.sh.locked
done<${SAMPLESHEETSDIR}/allSampleSheets_Zinc.txt

trap - EXIT
exit 0
