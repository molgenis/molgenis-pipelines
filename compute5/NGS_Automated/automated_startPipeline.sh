#!/bin/bash
set -e 
set -u

groupname=$1

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )
##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
echo $myhost
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

#ls ${SAMPLESHEETSDIR}/*.csv > ${SAMPLESHEETSDIR}/allSampleSheets_Zinc_startPipeline.txt 
pipeline="dna"

AUTOMATEDVERSION=$(module list | grep -o -P 'Automated(.+)' | awk -F"/" '{print $2}' )

#NGS_DNA-3.2.2="NGS_DNA/3.2.2-Molgenis-Compute-v16.04.1-Java-1.8.0_45"
NGS_DNA_3_2_3="NGS_DNA/3.2.3-Molgenis-Compute-v16.05.1-Java-1.8.0_45"


if [ "${pipeline}" == "dna" ] 
then
	module load ${NGS_DNA_3_2_3}
fi

count=0 echo "Logfiles will be written to $LOGDIR"

for i in $(ls ${SAMPLESHEETSDIR}/*.csv) 
do
	echo "$i"
  	csvFile=$(basename $i)
        filePrefix="${csvFile%.*}"
	
	##get header to decide later which column is project
	HEADER=$(head -1 ${i})

	##Remove header, only want to keep samples
	sed '1d' $i > ${i}.tmp
	OLDIFS=$IFS
	IFS=','
	array=($HEADER)
	IFS=$OLDIFS
	count=1
	myproject=()

	for j in "${array[@]}"
	do
  		if [ "${j}" == "project" ]
  	     	then
			awk -F"," '{print $'$count'}' ${i}.tmp > ${i}.tmp2
  	 	fi
		count=$((count + 1))
	done
	cat ${i}.tmp2 | sort -V | uniq > ${i}.uniq.projects

        PROJECTARRAY=()
        while read line
        do
          	PROJECTARRAY+="${line} "

        done<${i}.uniq.projects

        OLDIFS=$IFS
        IFS=_
	set $filePrefix
        sequencer=$2
        run=$3
	IFS=$OLDIFS
        LOGGER=${LOGDIR}/${myproject}.startPipeline.logger

	####
	### Decide if the scripts should be created (per Samplesheet)
	##
	#
	if [[ -f $LOGDIR/${filePrefix}.dataCopiedToZinc && ! -f $LOGDIR/${filePrefix}.scriptsGenerated ]]
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
			echo "copying $EBROOTNGS_AUTOMATED/automated_generate_template.sh to ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh" >> $LOGGER
                       	cp ${EBROOTNGS_AUTOMATED}/automated_generate_template.sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh
		
			if [ -f ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv ]
			then
				echo "${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv already existed, will now be removed and will be replaced by a fresh copy" >> $LOGGER
				rm ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv
			fi
		
			cp ${SAMPLESHEETSDIR}/${csvFile} ${GENERATEDSCRIPTS}/${run}_${sequencer}/${run}_${sequencer}.csv
		
			cd ${GENERATEDSCRIPTS}/${run}_${sequencer}/
			sh ${GENERATEDSCRIPTS}/${run}_${sequencer}/generate.sh "${run}_${sequencer}"
		
			cd scripts
			touch ${GENERATEDSCRIPTS}/${run}_${sequencer}/scripts/CopyPrmTmpData_0.sh.finished
			sh submit.sh
			pipelineVersion=$(module list | grep -o -P 'NGS_DNA(.+)')
			touch $LOGDIR/${filePrefix}.scriptsGenerated
		fi
	fi

	####
	### If generatedscripts is already done, step in this part to submit the jobs (per project)
	##
	#
	if [ -f $LOGDIR/${filePrefix}.scriptsGenerated ] 
	then
		for myproject in ${PROJECTARRAY[@]}
		do
			PROJECT=$myproject
			WHOAMI=$(whoami)
			HOSTN=$(hostname)

			if [[ -f $LOGDIR/${filePrefix}.dataCopiedToZinc && ! -f $LOGDIR/${myproject}.pipeline.started ]]
			cd ${PROJECTSDIR}/${PROJECT}/run01/jobs/
			sh submit.sh

			touch ${LOGDIR}/${PROJECT}.pipeline.started

			printf "Pipeline: ${pipeline}\nStarttime:`date +%d/%m/%Y` `date +%H:%M`\nProject: $PROJECT\nStarted by: $WHOAMI\nHost: ${HOSTN}\n\nProgress can be followed via the command squeue -u $WHOAMI on $HOSTN.\nYou will receive an email when the pipeline is finished!\n\nCheers from the GCC :)" | mail -s "NGS_DNA pipeline is started for project $PROJECT on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
			sleep 40
        	fi
	done
done
