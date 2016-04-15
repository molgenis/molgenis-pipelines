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
	rm ${LOGDIR}/automated_copyDataToPrm.sh.locked
}
trap finish ERR

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

        if [ -f ${LOGDIR}/automated_copyDataToPrm.sh.locked ]
        then
            	exit 0
	else
		touch ${LOGDIR}/automated_copyDataToPrm.sh.locked
        fi

	copyRawZincToPrm="${RAWDATADIR}/${filePrefix}/* umcg-gaf-dm@calculon.hpc.rug.nl:${RAWDATADIRPRM}/${filePrefix}"
	makeRawDataDir=$(ssh umcg-gaf-dm@calculon.hpc.rug.nl "sh ${RAWDATADIRPRM}../checkRawData.sh ${RAWDATADIRPRM} ${filePrefix}")

	if [[ -f $LOGDIR/${filePrefix}.dataCopiedToZinc && ! -f $LOGDIR/${filePrefix}.dataCopiedToPrm ]]
	then
		echo "1"
		countFilesRawDataDirTmp=$(ls ${RAWDATADIR}/${filePrefix}/*.fq.gz* | wc -l)
		if [ "${makeRawDataDir}" == "f" ]
		then
			echo "copying data from zinc to prm" >> ${LOGGER}
                        rsync -r -a ${copyRawZincToPrm}
			makeRawDataDir="t"
		fi
		if [ "${makeRawDataDir}" == "t" ]
                then
                        countFilesRawDataDirPrm=$(ssh umcg-gaf-dm@calculon.hpc.rug.nl "ls ${RAWDATADIRPRM}/${filePrefix}/*.fq.gz* | wc -l")
                        if [ ${countFilesRawDataDirTmp} -eq ${countFilesRawDataDirPrm} ]
                        then
                                COPIEDTOPRM=$(ssh umcg-gaf-dm@calculon.hpc.rug.nl "sh ${RAWDATADIRPRM}../check.sh ${RAWDATADIRPRM} ${filePrefix}")
				if [[ "${COPIEDTOPRM}" == *"FAILED"* ]]
                                then
                                        echo "md5sum check failed, the copying will start again" >> ${LOGGER}
                                        rsync -r -a ${copyRawZincToPrm}
					echo "copy failed" >> $LOGDIR/${filePrefix}.failed
                                elif [[ "${COPIEDTOPRM}" == *"PASS"* ]]
                                then
                                        touch $LOGDIR/${filePrefix}.dataCopiedToPrm
					scp ${SAMPLESHEETSDIR}/${csvFile} umcg-gaf-dm@calculon.hpc.rug.nl:${SAMPLESHEETSPRMDIR}
					echo "copied ${csvFile} to ${SAMPLESHEETSPRMDIR} on calculon" >> ${LOGGER}
					printf "De data voor project ${filePrefix} is gekopieerd naar ${RAWDATADIRPRM}" | mail -s "${filePrefix} copied to permanent storage" ${ONTVANGER}
				  	if [ -f $LOGDIR/${filePrefix}.failed ] 
                                        then
						rm $LOGDIR/${filePrefix}.failed
					fi
                                fi
                        else
				echo "copying data..." >> $LOGGER
                                rsync -r -a ${copyRawZincToPrm}
                        fi
                fi
        fi

	if [ -f $LOGDIR/${filePrefix}.failed ]
	then
		COUNT=$(cat $LOGDIR/${filePrefix}.failed | wc -l)
		if [ $COUNT == 10  ]
		then
			HOSTNA=$(hostname)
			printf "De md5sum checks voor project ${filePrefix} op ${RAWDATADIRPRM} zijn mislukt.De originele data staat op ${HOSTNA}:${RAWDATADIR}\n\nDeze mail is verstuurd omdat er al 10 pogingen zijn gedaan om de data te kopieren/md5summen" | mail -s "${filePrefix} failing to copy to permanent storage" ${ONTVANGER}
		fi
	fi
	rm ${LOGDIR}/automated_copyDataToPrm.sh.locked
done<${SAMPLESHEETSDIR}/allSampleSheets_Zinc.txt
