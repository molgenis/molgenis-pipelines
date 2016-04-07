#!/bin/bash
set -e
set -u

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )
##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
echo $myhost

. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

### VERVANG DOOR UMCG-ATEAMBOT USER
ls ${SAMPLESHEETSDIR}/*.csv > ${SAMPLESHEETSDIR}/allSampleSheets_Zinc_startPipeline.txt

pipeline="dna"
count=0
echo "Logfiles will be written to $LOGDIR"

for i in $(ls ${SAMPLESHEETSDIR}/*.csv)
do
  	csvFile=$(basename $i)
        filePrefix="${csvFile%.*}"

	HEADER=$(head -1 ${i})
	OLDIFS=$IFS
	IFS=','
	array=($HEADER)
	IFS=$OLDIFS
	count=1
	myproject=""

	for j in "${array[@]}"
	do
  		if [ "${j}" == "project" ]
  	     	then
  	        	myproject=$(awk '{FS=","}{print $'$count'}' $i | uniq)
  	      	fi
		count=$((count + 1))
	done

	echo "myproject: $myproject"
        FINISHED="no"
        OLDIFS=$IFS
        IFS=_
	set $filePrefix
        sequencer=$2
        run=$3
	IFS=$OLDIFS
        LOGGER=${LOGDIR}/${myproject}.startPipeline.logger

        if [ -f ${LOGDIR}/${myproject}.startPipeline.locked ]
        then
            	exit 0
        fi

	if [[ -f $LOGDIR/${filePrefix}.dataCopiedToZinc && ! -f $LOGDIR/${myproject}.pipeline.started ]]
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
				module load NGS_DNA
				pipelineVersion=$(module list | grep -o -P 'NGS_DNA(.+)')
				printf "The version which is now loaded is $pipelineVersion${normal}\n\n"
			fi
                        mkdir -p ${GENERATEDSCRIPTS}/${run}_${sequencer}/
			echo "copying $EBROOTNGS_DNA/automated/automated_generate_template.sh to ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh" >> $LOGGER
                        cp $EBROOTNGS_DNA/automated/automated_generate_template.sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh
			if [ -f ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv ]
			then
				echo "${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv already existed, will now be removed and will be replaced by a fresh copy" >> $LOGGER
				rm ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv
			fi

			cp ${SAMPLESHEETSDIR}/${csvFile} ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv
			cd ${GENERATEDSCRIPTS}/${run}_${sequencer}/
			sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh "${run}_${sequencer}" "${TMPDIR}"
			cd scripts

			touch ${GENERATEDSCRIPTS}/${run}_${sequencer}/scripts/CopyPrmTmpData_0.sh.finished
			sh submit.sh
			if [ -f ${myproject}.failed.txt ]
			then
				PROJECT=$myproject
				WHOAMI=$(whoami)
				HOSTN=$(hostname)
				pipelineVersion=$(module list | grep -o -P 'NGS_DNA(.+)')
				printf "Pipeline: ${pipelineVersion}\nStarttime:`date +%d/%m/%Y` `date +%H:%M`\nProject: $PROJECT\nStarted by: $WHOAMI\nHost: ${HOSTN}\n\nProgress can be followed via the command squeue -u $WHOAMI on $HOSTN.\nYou will receive an email when the pipeline is finished!\n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is started for project $PROJECT on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
			fi

		else
              		echo "Pipeline is skipped" >> ${LOGGER}
                fi
        fi
	rm ${LOGDIR}/${myproject}.startPipeline.locked
	
done
