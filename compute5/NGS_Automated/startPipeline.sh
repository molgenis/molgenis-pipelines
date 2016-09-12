#!/bin/bash
set -e 
set -u

groupname=$1

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )
##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)

. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

pipeline="dna"

NGS_DNA="NGS_DNA/3.2.5"

if [ "${pipeline}" == "dna" ] 
then
	module load ${NGS_DNA}
fi

count=0 
echo "Logfiles will be written to $LOGDIR"

for i in $(ls ${SAMPLESHEETSDIR}/*.csv) 
do
  	csvFile=$(basename $i)
        filePrefix="${csvFile%.*}"

	##get header to decide later which column is project
	HEADER=$(head -1 ${i})

	##Remove header, only want to keep samples
	sed '1d' $i > ${LOGDIR}/TMP/${filePrefix}.tmp
	OLDIFS=$IFS
	IFS=','
	array=($HEADER)
	IFS=$OLDIFS
	count=1
	for j in "${array[@]}"
	do
  		if [ "${j}" == "project" ]
  	     	then
			awk -F"," '{print $'$count'}' ${LOGDIR}/TMP/${filePrefix}.tmp > ${LOGDIR}/TMP/${filePrefix}.tmp2
  	 	fi
		count=$((count + 1))
	done
	cat ${LOGDIR}/TMP/${filePrefix}.tmp2 | sort -V | uniq > ${LOGDIR}/TMP/${filePrefix}.uniq.projects

        PROJECTARRAY=()
        while read line
        do
          	PROJECTARRAY+="${line} "

        done<${LOGDIR}/TMP/${filePrefix}.uniq.projects
	count=1

	## Know which capturing kits
	for j in "${array[@]}"
	do
  		if [ "${j}" == "capturingKit" ]
  	     	then

			awk -F"," '{print $'$count'}' ${LOGDIR}/TMP/${filePrefix}.tmp > ${LOGDIR}/TMP/${filePrefix}.capturingKit
  	 	fi
		count=$((count + 1))
	done
	cat ${LOGDIR}/TMP/${filePrefix}.capturingKit | sort -V | uniq > ${LOGDIR}/TMP/${filePrefix}.uniq.capturingKits	
	miSeqRun="no"
	while read line
        do
        	if [[ "${line}" == *"CARDIO_v"* || "${line}" == *"DER_v"* || "${line}" == *"DYS_v"* || "${line}" == *"EPI_v"* || "${line}" == *"LEVER_v"* || "${line}" == *"NEURO_v"* || "${line}" == *"ONCO_v"* || "${line}" == *"PCS_v"* ]]
		then
			miSeqRun="yes"
			break
		fi
        done<${LOGDIR}/TMP/${filePrefix}.uniq.capturingKits

        OLDIFS=$IFS
        IFS=_
	set $filePrefix
        sequencer=$2
        run=$3
	IFS=$OLDIFS
        LOGGER=${LOGDIR}/${filePrefix}/${filePrefix}.pipeline.logger

	####
	### Decide if the scripts should be created (per Samplesheet)
	##
	#
	if [[ -f $LOGDIR/${filePrefix}/${filePrefix}.dataCopiedToDiagnosticsCluster  && ! -f $LOGDIR/${filePrefix}/${filePrefix}.scriptsGenerated ]]
        then
               	### Step 4: Does the pipeline need to run?
               	if [ "${pipeline}" == "RNA-Lexogen-reverse" ]
               	then
               	        echo "RNA-Lexogen-reverse" >> ${LOGGER}
               	elif [ "${pipeline}" == "RNA-Lexogen" ]
               	then
               	        echo "RNA-Lexogen" >> ${LOGGER}
               	elif [ "${pipeline}" == "RNA" ]
               	then
               	        echo "RNA" >> ${LOGGER}
               	elif [ "${pipeline}" == "dna" ]
               	then
			if pipelineVersion=$(module list | grep -o -P 'NGS_DNA(.+)')
			then
				echo ""
			else
				underline=`tput smul`
				normal=`tput sgr0`
				bold=`tput bold`
				printf "${bold}WARNING: there is no pipeline version loaded, this can be because this script is run manually.\nA default version of the NGS_DNA pipeline will be loaded!\n\n"
				module load $DNA
				pipelineVersion=$(module list | grep -o -P 'NGS_DNA(.+)')
				printf "The version which is now loaded is $pipelineVersion${normal}\n\n"
			fi
                       	mkdir -p ${GENERATEDSCRIPTS}/${run}_${sequencer}/

			batching="_chr"

			if [ "${miSeqRun}" == "yes" ]
			then
				batching="_small"
			fi

			echo "copying $EBROOTNGS_AUTOMATED/automated_generate_template.sh to ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh" >> $LOGGER
                       	cp ${EBROOTNGS_AUTOMATED}/automated_generate_template.sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh

			if [ -f ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv ]
			then
				echo "${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv already existed, will now be removed and will be replaced by a fresh copy" >> $LOGGER
				rm ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv
			fi

			cp ${SAMPLESHEETSDIR}/${csvFile} ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv

			cd ${GENERATEDSCRIPTS}/${run}_${sequencer}/

			sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh "${run}_${sequencer}" ${batching} > ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.logger 2>&1 

			cd scripts

			sh submit.sh
			touch $LOGDIR/${filePrefix}/${filePrefix}.scriptsGenerated
		fi
	fi

	####
	### If generatedscripts is already done, step in this part to submit the jobs (per project)
	##
	#
	if [ -f $LOGDIR/${filePrefix}/${filePrefix}.scriptsGenerated ] 
	then
		for PROJECT in ${PROJECTARRAY[@]}
		do
			if [ ! -d ${LOGDIR}/${PROJECT} ]
			then
				mkdir ${LOGDIR}/${PROJECT}
			fi
 
			WHOAMI=$(whoami)
			HOSTN=$(hostname)
		        LOGGER=${LOGDIR}/${PROJECT}/${PROJECT}.pipeline.logger
			if [ ! -f ${LOGDIR}/${PROJECT}/${PROJECT}.pipeline.started ]
			then
				cd ${PROJECTSDIR}/${PROJECT}/run01/jobs/
				sh submit.sh

				touch ${LOGDIR}/${PROJECT}/${PROJECT}.pipeline.started
				echo "${PROJECT} started" >> $LOGGER

				printf "Pipeline: ${pipeline}\nStarttime:`date +%d/%m/%Y` `date +%H:%M`\nProject: $PROJECT\nStarted by: $WHOAMI\nHost: ${HOSTN}\n\nProgress can be followed via the command squeue -u $WHOAMI on $HOSTN.\nYou will receive an email when the pipeline is finished!\n\nCheers from the GCC :)" | mail -s "NGS_DNA pipeline is started for project $PROJECT on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
				sleep 40
			fi
		done
	fi
done
