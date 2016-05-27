set -e
set -u

GAT=$1
groupname=$2
gattacaAddress="${GAT}.gcc.rug.nl"
echo $gattacaAddress
MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

### VERVANG DOOR UMCG-ATEAMBOT USER
ssh umcg-ateambot@${gattacaAddress} "ls ${GATTACA}/Samplesheets/*.csv" > ${SAMPLESHEETSDIR}/allSampleSheets_${GAT}.txt


echo "Logfiles will be written to $LOGDIR"
while read line
do
	csvFile=$(basename $line)
	filePrefix="${csvFile%.*}"
	LOGGER=${LOGDIR}/${filePrefix}.copyToZinc.logger

	function finish {
        	echo "TRAPPED"
        	rm ${LOGDIR}/${filePrefix}.copyToZinc.locked
	}
	trap finish ERR

	FINISHED="no"
	OLDIFS=$IFS
	IFS=_
	set $filePrefix
	sequencer=$2
	run=$3
	IFS=$OLDIFS
	if ssh umcg-ateambot@${gattacaAddress} ls ${GATTACA}/logs/${filePrefix}.demultiplexing.finished 1> /dev/null 2>&1 
	then
		### Demultiplexing is finished
		printf ""
	else
		continue;
	fi

	if [ -f ${LOGDIR}/${filePrefix}.copyToZinc.locked ]
	then
		exit 0
	fi
	touch ${LOGDIR}/${filePrefix}.copyToZinc.locked

	## Check if samplesheet is copied
	copyRawGatToZinc="umcg-ateambot@${gattacaAddress}:${GATTACA}/runs/run_${run}_${sequencer}/results/${filePrefix}* ${RAWDATADIR}/$filePrefix"

	if [[ ! -f ${SAMPLESHEETSDIR}/$csvFile || ! -f $LOGDIR/${filePrefix}.SampleSheetCopied ]]
        then
                scp umcg-ateambot@${gattacaAddress}:${GATTACA}/Samplesheets/${csvFile} ${SAMPLESHEETSDIR}
                touch $LOGDIR/${filePrefix}.SampleSheetCopied
        fi
	## Check if data is already copied to tmp05 on zinc-finger

	if [ ! -d ${RAWDATADIR}/$filePrefix ]
	then
		mkdir -p ${RAWDATADIR}/${filePrefix}/Info
		echo "Copying data to zinc.." >> $LOGGER
		rsync -r -a ${copyRawGatToZinc}
	fi


	if [[ -d ${RAWDATADIR}/$filePrefix  && ! -f $LOGDIR/${filePrefix}.dataCopiedToZinc ]]
	then
		##Compare how many files are on both the servers in the directory
		countFilesRawDataDirTmp=$(ls ${RAWDATADIR}/${filePrefix}/${filePrefix}* | wc -l)
		countFilesRawDataDirGattaca=$(ssh umcg-ateambot@${gattacaAddress} "ls ${GATTACA}/runs/run_${run}_${sequencer}/results/${filePrefix}* | wc -l ")

		rsync -r umcg-ateambot@${gattacaAddress}:/groups/umcg-lab/scr01/sequencers/${filePrefix}/InterOp ${RAWDATADIR}/${filePrefix}/Info/
		rsync umcg-ateambot@${gattacaAddress}:/groups/umcg-lab/scr01/sequencers/${filePrefix}/RunInfo.xml ${RAWDATADIR}/${filePrefix}/Info/
		rsync umcg-ateambot@${gattacaAddress}:/groups/umcg-lab/scr01/sequencers/${filePrefix}/*unParameters.xml ${RAWDATADIR}/${filePrefix}/Info/

		if [ ${countFilesRawDataDirTmp} -eq ${countFilesRawDataDirGattaca} ]
		then
			cd ${RAWDATADIR}/${filePrefix}/
			for i in $(ls *.fq.gz.md5 )
			do
				if md5sum -c $i
				then
					echo "data copied to zinc" >> $LOGGER
					touch $LOGDIR/${filePrefix}.dataCopiedToZinc
					touch ${filePrefix}.md5sums.checked
					rm ${LOGDIR}/${filePrefix}.copyToZinc.locked
				else
					echo "md5sum check failed, the copying will start again" >> $LOGGER
					rsync -r -a ${copyRawGatToZinc}
                                	echo "data copied to Zinc" >> $LOGGER
				fi
			done
		else
			echo "Retry: Copying data to zinc" >> $LOGGER
			rsync -r -a ${copyRawGatToZinc}
			echo "data copied to Zinc" >> $LOGGER
		fi
	fi
rm ${LOGDIR}/${filePrefix}.copyToZinc.locked
done<${SAMPLESHEETSDIR}/allSampleSheets_${GAT}.txt
