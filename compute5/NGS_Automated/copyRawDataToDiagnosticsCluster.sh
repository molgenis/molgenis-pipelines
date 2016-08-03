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

gattacaSamplesheets=()

while read line 
do
	gattacaSamplesheets+=("${line} ")
done<${SAMPLESHEETSDIR}/allSampleSheets_${GAT}.txt

echo "Logfiles will be written to $LOGDIR"

for line in ${gattacaSamplesheets[@]}
do
	csvFile=$(basename $line)
	filePrefix="${csvFile%.*}"
	LOGGER=${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.logger

	if [ ! -d ${LOGDIR}/${filePrefix}/ ]
	then
		mkdir ${LOGDIR}/${filePrefix}/
	fi
 
	function finish {
		if [ -f ${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.locked ]
        	then
	        	echo "TRAPPED"
        		rm ${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.locked
		fi
	}
	trap finish HUP INT QUIT TERM EXIT ERR

	FINISHED="no"
	OLDIFS=$IFS
	IFS=_
	set $filePrefix
	sequencer=$2
	run=$3
	IFS=$OLDIFS

	if ssh umcg-ateambot@${gattacaAddress} ls ${GATTACA}/logs/${filePrefix}_Demultiplexing.finished 1> /dev/null 2>&1 
	then
		### Demultiplexing is finished
		printf ""
	else
		continue;
	fi

	if [ -f $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToDiagnosticsCluster ]
	then
		continue;
	fi

	if [ -f ${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.locked ]
	then
		exit 0
	fi
	touch ${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.locked

	## Check if samplesheet is copied
	copyRawGatToDiagnosticsCluster="umcg-ateambot@${gattacaAddress}:${GATTACA}/runs/run_${run}_${sequencer}/results/${filePrefix}* ${RAWDATADIR}/$filePrefix"

	if [[ ! -f ${SAMPLESHEETSDIR}/$csvFile || ! -f $LOGDIR/${filePrefix}/${filePrefix}.SampleSheetCopied ]]
        then
                scp umcg-ateambot@${gattacaAddress}:${GATTACA}/Samplesheets/${csvFile} ${SAMPLESHEETSDIR}
                touch $LOGDIR/${filePrefix}/${filePrefix}.SampleSheetCopied
        fi
	## Check if data is already copied to DiagnosticsCluster

	if [ ! -d ${RAWDATADIR}/$filePrefix ]
	then
		mkdir -p ${RAWDATADIR}/${filePrefix}/Info
		echo "Copying data to DiagnosticsCluster.." >> $LOGGER
		rsync -r -a ${copyRawGatToDiagnosticsCluster}
	fi


	if [[ -d ${RAWDATADIR}/$filePrefix  && ! -f $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToDiagnosticsCluster ]]
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
					
					awk '{print $2" CHECKED, and is correct"}' $i >> $LOGGER
				else
					echo "md5sum check failed, the copying will start again" >> $LOGGER
					rsync -r -a ${copyRawGatToDiagnosticsCluster}
					echo -e "data copied to DiagnosticsCluster \n" >> $LOGGER
		
				fi
			done
			touch $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToDiagnosticsCluster
			touch ${filePrefix}.md5sums.checked

		else
			echo "Retry: Copying data to DiagnosticsCluster" >> $LOGGER
			rsync -r -a ${copyRawGatToDiagnosticsCluster}
			echo "data copied to DiagnosticsCluster" >> $LOGGER
		fi
	fi
rm ${LOGDIR}/${filePrefix}/${filePrefix}.copyToDiagnosticsCluster.locked
done

trap - EXIT
exit 0
