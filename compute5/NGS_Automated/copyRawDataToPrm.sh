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
ls ${SAMPLESHEETSDIR}/*.csv > ${SAMPLESHEETSDIR}/allSampleSheets_DiagnosticsCluster.txt
pipeline="dna"

function finish {
	echo "TRAPPED"
		rm -f ${LOGDIR}/copyDataToPrm.sh.locked
}
trap finish HUP INT QUIT TERM EXIT ERR

ARR=()
while read i
do
ARR+=($i)
done<${SAMPLESHEETSDIR}/allSampleSheets_DiagnosticsCluster.txt

echo "Logfiles will be written to $LOGDIR"
for line in ${ARR[@]}
do
        csvFile=$(basename $line)
        filePrefix="${csvFile%.*}"
        LOGGER=${LOGDIR}/${filePrefix}/${filePrefix}.copyToPrm.logger

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

	##get header to decide later which column is project
        HEADER=$(head -1 ${line})

	##Remove header, only want to keep samples
        sed '1d' $line > ${LOGDIR}/TMP/${filePrefix}.utmp
        OLDIFS=$IFS
        IFS=','
        array=($HEADER)
        IFS=$OLDIFS
        count=1
        for j in "${array[@]}"
        do
          	if [ "${j}" == "project" ]
                then
                    	awk -F"," '{print $'$count'}' ${LOGDIR}/TMP/${filePrefix}.utmp > ${LOGDIR}/TMP/${filePrefix}.utmp2
                fi
                count=$((count + 1))
        done
	cat ${LOGDIR}/TMP/${filePrefix}.utmp2 | sort -V | uniq > ${LOGDIR}/TMP/${filePrefix}.unique.projects

        PROJECTARRAY=()
        while read line
        do
          	PROJECTARRAY+="${line} "

        done<${LOGDIR}/TMP/${filePrefix}.unique.projects



	copyRawDiagnosticsClusterToPrm="${RAWDATADIR}/${filePrefix}/* ${groupname}-dm@calculon.hpc.rug.nl:${RAWDATADIRPRM}/${filePrefix}"
	makeRawDataDir=$(ssh ${groupname}-dm@calculon.hpc.rug.nl "sh ${RAWDATADIRPRM}/../checkRawData.sh ${RAWDATADIRPRM} ${filePrefix}")

	if [[ -f $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToDiagnosticsCluster && ! -f $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToPrm ]]
	then
		echo "working on ${filePrefix}"
		countFilesRawDataDirTmp=$(ls ${RAWDATADIR}/${filePrefix}/${filePrefix}* | wc -l)
		if [ "${makeRawDataDir}" == "f" ]
		then
			echo "copying data from DiagnosticsCluster to prm" >> ${LOGGER}
                        rsync -r -av ${copyRawDiagnosticsClusterToPrm} >> $LOGGER
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
                                        rsync -r -av ${copyRawDiagnosticsClusterToPrm} >> $LOGGER 2>&1
					echo "copy failed" >> $LOGDIR/${filePrefix}/${filePrefix}.failed
                                elif [[ "${COPIEDTOPRM}" == *"PASS"* ]]
                                then
					scp ${SAMPLESHEETSDIR}/${csvFile} ${groupname}-dm@calculon.hpc.rug.nl:${RAWDATADIRPRM}/${filePrefix}/
					scp ${SAMPLESHEETSDIR}/${csvFile} ${groupname}-dm@calculon.hpc.rug.nl:${SAMPLESHEETSPRMDIR}
					echo "finished copying data to calculon" >> ${LOGGER}
					
					echo "finished with rawdata" >> ${LOGDIR}/${filePrefix}/${filePrefix}.copyToPrm.logger

					if ls ${RAWDATADIR}/${filePrefix}/${filePrefix}*.log 1> /dev/null 2>&1
					then
						logFileStatistics=$(cat ${RAWDATADIR}/${filePrefix}/${filePrefix}*.log)
						if [ ${groupname} == "umcg-gaf" ]
						then
							echo -e "Demultiplex statistics ${filePrefix}: \n\n ${logFileStatistics}" | mail -s "Demultiplex statistics ${filePrefix}" ${GAFmail}
						fi
						echo -e "De data voor project ${filePrefix} is gekopieerd naar ${RAWDATADIRPRM}" | mail -s "${filePrefix} copied to permanent storage" ${ONTVANGER}
						touch $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToPrm
					fi
						rm -f $LOGDIR/${filePrefix}/${filePrefix}.failed
                                fi
                        else
				echo "$filePrefix: $countFilesRawDataDirTmp | $countFilesRawDataDirPrm"
				echo "copying data..." >> $LOGGER
                                rsync -r -av ${copyRawDiagnosticsClusterToPrm} >> $LOGGER 2>&1
                        fi
                fi
        fi

	if [ -f $LOGDIR/${filePrefix}/${filePrefix}.failed ]
	then
		COUNT=$(cat $LOGDIR/${filePrefix}/${filePrefix}.failed | wc -l)
		if [ $COUNT == 10  ]
		then
			HOSTNA=$(hostname)
			echo -e "De md5sum checks voor project ${filePrefix} op ${RAWDATADIRPRM} zijn mislukt.De originele data staat op ${HOSTNA}:${RAWDATADIR}\n\nDeze mail is verstuurd omdat er al 10 pogingen zijn gedaan om de data te kopieren/md5summen" | mail -s "${filePrefix} failing to copy to permanent storage" ${ONTVANGER}
		fi
	fi
	rm -f ${LOGDIR}/copyDataToPrm.sh.locked
done<${SAMPLESHEETSDIR}/allSampleSheets_DiagnosticsCluster.txt

trap - EXIT
exit 0
