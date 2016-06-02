#!/bin/bash
set -e
set -u

##Demultiplexing module will be loaded via cronjob
module list

MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
if [[ $myhost == *"gattaca"* ]]
then
	echo $myhost
	. ${MYINSTALLATIONDIR}/gattaca.cfg
else
	echo $myhost
	. ${MYINSTALLATIONDIR}/${myhost}.cfg
fi
GROUP=""
### Sequencer is writing to this location: $NEXTSEQDIR
### Looping through to see if all files
for i in $(ls -1 -d ${NEXTSEQDIR}/*/)
do
	## PROJECTNAME is sequencingStartDate_sequencer_run_flowcell
	PROJECTNAME=$(basename ${i})
	OLDIFS=$IFS
	IFS=_
	set $PROJECTNAME
	sequencer=$2
	run=$3
	IFS=$OLDIFS

	miseqCompleted="no"

        ## Check if there the run is already completed
        if [[ -f ${NEXTSEQDIR}/${PROJECTNAME}/RTAComplete.txt ]] && [[ "${sequencer}" == "M01785" || "${sequencer}" == "M01997" ]]
        then
            	miSeqCompleted="yes"
        fi

	## Check if there the run is already completed
	if [[ -f ${NEXTSEQDIR}/${PROJECTNAME}/RunCompletionStatus.xml || "${miSeqCompleted}" == "yes" ]]
	then
		##Check if it is a GAF or GD run
		if [ -f "${ROOTDIR}/umcg-gaf/${SCRATCHDIR}/Samplesheets/${PROJECTNAME}.csv" ]
		then
			GROUP="umcg-gaf"
		elif [ -f "${ROOTDIR}/umcg-gd/${SCRATCHDIR}/Samplesheets/${PROJECTNAME}.csv" ]
		then
			GROUP="umcg-gd"
		else
			SAMPLESHEETSDIR=${MISSINGSAMPLESHEETSDIR}
			DEBUGGER=${SAMPLESHEETSDIR}/${PROJECTNAME}_logger.txt
			
			echo "${PROJECTNAME}: Samplesheet is not there!"
			if [ ! -f ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.mailed ]
                        then
                               	if [ -f ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt ]
                                then
	                               	echo  "Samplesheet is not available" >> ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt
					COUNT=$(cat ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt | wc -l)
				        if [ $COUNT == 10 ]
        				then
			                    	echo "Er is geen samplesheet gevonden op deze locatie: ${SAMPLESHEETSDIR}/${PROJECTNAME}.csv" | mail -s "Er is geen samplesheet gevonden voor ${PROJECTNAME}" ${ONTVANGER}
                       				echo "mail has been sent to ${ONTVANGER}"
                       				touch ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.mailed
			                        echo "mail send to ${ONTVANGER}" >> ${DEBUGGER}
                			fi
                                else
                                      	echo  "Samplesheet is not available" >> ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt
                                        echo "Samplesheet is missing, after 10 times a mail will be send to the user" >> ${DEBUGGER}
                                fi
			fi
			## go to next sample 
			continue
		fi
		
		### SETTING PATHS
		WORKDIR="${ROOTDIR}/${GROUP}/${SCRATCHDIR}"
		LOGSDIR=${WORKDIR}/logs
		SAMPLESHEETSDIR=${WORKDIR}/Samplesheets
		DEBUGGER=${LOGSDIR}/${PROJECTNAME}_logger.txt
		### Check if the demultiplexing is already started
		
		if [ ! -f ${LOGSDIR}/${PROJECTNAME}_Demultiplexing.started ]
		then
			python ${EBROOTNGS_DEMULTIPLEX}/automated_demultiplexing/checkSampleSheet.py --input ${SAMPLESHEETSDIR}/${PROJECTNAME}.csv --logfile ${DEBUGGER}.error
			if [ $? == 1 ]
			then
				cat  ${DEBUGGER}.error | mail -s "Samplesheet error ${PROJECTNAME}" ${ONTVANGER}
				rm ${DEBUGGER}.error
				exit 1
			else
				echo  "Samplesheet is OK" >> ${DEBUGGER}
				#####
				## RUN PIPELINE PART ##
				#####
				RUNFOLDER="run_${run}_${sequencer}"
				LOGGERPIPELINE=${WORKDIR}/generatedscripts/${RUNFOLDER}/logger.txt
				echo "All checks are done. Logging from now on can be found: ${LOGGERPIPELINE}" >> ${DEBUGGER}

				## Check if Check file (if samplesheet is already there) is existing
                     		if [ -f ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt ]
				then
					## Remove tmp Check file
                                        rm ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt
					echo "rm ${SAMPLESHEETSDIR}/${PROJECTNAME}_Check.txt" >> ${LOGGERPIPELINE}
                               	fi

					### Check if runfolder already exists
				if [ ! -d ${WORKDIR}/generatedscripts/${RUNFOLDER} ]
				then
					mkdir -p ${WORKDIR}/generatedscripts/${RUNFOLDER}/
					echo "mkdir -p ${WORKDIR}/generatedscripts/${RUNFOLDER}/" >> ${LOGGERPIPELINE}
				fi

				## Direct to generatedscripts folder
				cd ${WORKDIR}/generatedscripts/${RUNFOLDER}/

				## Copy generate script and samplesheet
				cp ${SAMPLESHEETSDIR}/${PROJECTNAME}.csv run_${run}_${sequencer}.csv
				echo "copied ${SAMPLESHEETSDIR}/${PROJECTNAME}.csv to run_${run}_${sequencer}.csv" >> ${LOGGERPIPELINE}

                       		cp ${EBROOTNGS_DEMULTIPLEX}/generate_template.sh ./
				echo "Copied ${EBROOTNGS_DEMULTIPLEX}/generate_template.sh to ." >> ${LOGGERPIPELINE}
				echo "" >> ${LOGGERPIPELINE}

				### Generating scripts
				echo "Generated scripts" >> ${LOGGERPIPELINE}
				sh generate_template.sh ${sequencer} ${run} ${WORKDIR} ${GROUP} 2>&1 >> ${LOGGERPIPELINE}
				echo "cd ${WORKDIR}/runs/${RUNFOLDER}/jobs" >> ${LOGGERPIPELINE}
				cd ${WORKDIR}/runs/${RUNFOLDER}/jobs

				sh submit.sh
				echo "jobs submitted, pipeline is running" >> ${LOGGERPIPELINE}
                      		touch ${LOGSDIR}/${PROJECTNAME}_Demultiplexing.started
				echo "De demultiplexing pipeline is gestart, over een aantal uren zal dit klaar zijn \
				en word de data automatisch naar zinc-finger gestuurd, hierna  word de pipeline gestart" | mail -s "Het demultiplexen van ${PROJECTNAME} is gestart op (`date +%d/%m/%Y` `date +%H:%M`)" ${ONTVANGER}
			fi
                fi
	fi
done
