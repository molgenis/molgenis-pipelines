set -e
set -u

GAT=$1

gattacaAddress="${GAT}.gcc.rug.nl"
echo $gattacaAddress
MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${myhost}.cfg

### VERVANG DOOR UMCG-ATEAMBOT USER
ssh umcg-rkanninga@${gattacaAddress} "ls ${GATTACA}/Samplesheets/*.csv" > ${SAMPLESHEETSDIR}/allSampleSheets_${GAT}.txt


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

	if [ -f ${LOGDIR}/${filePrefix}.copyToZinc.locked ]
	then
		exit 0
	fi
	touch ${LOGDIR}/${filePrefix}.copyToZinc.locked

	## Check if samplesheet is copied
	copyRawGatToZinc="umcg-rkanninga@${gattacaAddress}:${GATTACA}/runs/run_${run}_${sequencer}/results/*.fq.gz* ${RAWDATADIR}/$filePrefix"

 	if [ -f ${SAMPLESHEETSDIR}/$csvFile ]
	then
		touch $LOGDIR/${filePrefix}.SampleSheetCopied
	else
		scp umcg-rkanninga@${gattacaAddress}:${GATTACA}/Samplesheets/${csvFile} ${SAMPLESHEETSDIR}
		touch $LOGDIR/${filePrefix}.SampleSheetCopied

	fi
	if [ -d ${RAWDATADIR}/${filePrefix} ]
	then
		countFilesRawDataDirTmp=$(ls ${RAWDATADIR}/${filePrefix}/*.fq.gz* | wc -l)
	fi
	## Check if data is already copied to tmp05 on zinc-finger

	if [ ! -d ${RAWDATADIR}/$filePrefix ]
	then
		mkdir -p ${RAWDATADIR}/$filePrefix
		rsync -r -a ${copyRawGatToZinc}
	fi


	if [[ -d ${RAWDATADIR}/$filePrefix  && ! -f $LOGDIR/${filePrefix}.dataCopiedToZinc ]]
	then
		##Compare how many files are on both the servers in the directory
		countFilesRawDataDirGattaca=$(ssh umcg-rkanninga@${gattacaAddress} "ls ${GATTACA}/runs/run_${run}_${sequencer}/results/*.fq.gz* | wc -l ")
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
				else
					echo "md5sum check failed, the copying will start again" >> $LOGGER
					rsync -r -a ${copyRawGatToZinc}
                                	echo "data copied to Zinc" >> $LOGGER
				fi
			done
		else
			rsync -r -a ${copyRawGatToZinc}
			echo "data copied to Zinc" >> $LOGGER
		fi
	fi
rm ${LOGDIR}/${filePrefix}.copyToZinc.locked
done<${SAMPLESHEETSDIR}/allSampleSheets_${GAT}.txt
