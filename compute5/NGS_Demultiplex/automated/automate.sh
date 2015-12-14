set -e
set -u

module load NGS_Demultiplex

WORKDIR="/groups/umcg-gaf/tmp05/"
NEXTSEQDIR="${WORKDIR}/rawdata/nextseq/"
SAMPLESHEETDIR="${WORKDIR}/Samplesheets/"

### Sequencer is writing to this location: $NEXTSEQDIR
### Looping through to see if all files
for i in $(ls -1 -d ${NEXTSEQDIR}/*/)
do
	## PROJECTNAME is sequencingStartDate_sequencer_run_flowcell
	PROJECTNAME=$(basename ${i})
	DEBUGGER=${NEXTSEQDIR}/${PROJECTNAME}_logger.txt
	OLDIFS=$IFS
	IFS=_
	set $PROJECTNAME
	sequencer=$2
	run=$3
	IFS=$OLDIFS
	## Check if there the run is already completed
	if [ -f ${NEXTSEQDIR}/${PROJECTNAME}/RunCompletionStatus.xml  ]
	then
		### Check if data is already demultiplexed
		echo "(${PROJECTNAME}) Check if data is demultiplexed" >> ${DEBUGGER}
		if [ ! -f ${NEXTSEQDIR}/${PROJECTNAME}_Demultiplexing.finished ]
                then
			echo "Check if the demultiplexing is already started" >> ${DEBUGGER}
			### Check if the demultiplexing is already started
			if [ ! -f ${NEXTSEQDIR}/${PROJECTNAME}_Demultiplexing.started ]
			then
			### Check if Samplesheet is there
                        echo  "(${PROJECTNAME}) Check if Samplesheet is there" >> ${DEBUGGER}
                        	if [ -f ${SAMPLESHEETDIR}/${PROJECTNAME}.csv ]
                        	then
					echo  "Check samplesheet" >> ${DEBUGGER}
					python checkSampleSheet.py --input ${SAMPLESHEETDIR}/${PROJECTNAME}.csv
					if [ $? == 1 ]
					then
						echo "There is something wrong in the samplesheet! Exiting" >> ${DEBUGGER}
						exit 1
					else
						#####
						## RUN PIPELINE PART ##
						#####
						RUNFOLDER="run_${run}_${sequencer}"
						LOGGERPIPELINE=${WORKDIR}/generatedscripts/${RUNFOLDER}/logger.txt
						echo "All checks are done. Logging from now on can be found: ${LOGGERPIPELINE}" >> ${DEBUGGER}

						## Check if Check file (if samplesheet is already there) is existing
                               		 	if [ -f ${SAMPLESHEETDIR}/${PROJECTNAME}_Check.txt ]
						then
							## Remove tmp Check file
                                                        rm ${SAMPLESHEETDIR}/${PROJECTNAME}_Check.txt
							echo "rm ${SAMPLESHEETDIR}/${PROJECTNAME}_Check.txt" >> ${LOGGERPIPELINE}
                                		fi
						### Check if runfolder already exists
						if [ ! -d ${WORKDIR}/generatedscripts/$RUNFOLDER ]
						then
							mkdir -p ${WORKDIR}/generatedscripts/${RUNFOLDER}/
							echo "mkdir -p ${WORKDIR}/generatedscripts/${RUNFOLDER}/" >> ${LOGGERPIPELINE}
						fi

						## Direct to generatedscripts folder
						cd ${WORKDIR}/generatedscripts/${RUNFOLDER}/

						## Copy generate script and samplesheet
						cp ${SAMPLESHEETDIR}/${PROJECTNAME}.csv run_${run}_${sequencer}.csv
						echo "copied ${SAMPLESHEETDIR}/${PROJECTNAME}.csv to run_${run}_${sequencer}.csv" >> ${LOGGERPIPELINE}

                               			cp ${EBROOTNGS_DEMULTIPLEX}/generate_template.sh ./
						echo "Copied ${EBROOTNGS_DEMULTIPLEX}/generate_template.sh to ." >> ${LOGGERPIPELINE}
						echo "" >> ${LOGGERPIPELINE}

						### Generating scripts
						echo "Generated scripts" >> ${LOGGERPIPELINE}
						sh generate_template.sh ${sequencer} ${run}
						echo "cd ${WORKDIR}/runs/${RUNFOLDER}/jobs" >> ${LOGGERPIPELINE}
						cd ${WORKDIR}/runs/${RUNFOLDER}/jobs

						sh submit.sh
						echo "jobs submitted, pipeline is running" >> ${LOGGERPIPELINE}
                                       		touch ${NEXTSEQDIR}/${PROJECTNAME}_Demultiplexing.started

					fi
				fi
                        else
                                ## Do nothing
                                echo  "(${PROJECTNAME}) Check if Samplesheet is there --> Do nothing" >> ${DEBUGGER}
                                echo  "(${PROJECTNAME}) Do nothing" >> ${SAMPLESHEETDIR}/${PROJECTNAME}_Check.txt 
                        fi
                else
                        # Data is already demultiplexed
                        echo  "(${PROJECTNAME}) Data is already demultiplexed" >> ${DEBUGGER}

                fi
	else
		### Run is not completed yet
		echo "(${PROJECTNAME}) Run is not completed yet" >> ${DEBUGGER}
	fi
done
if [ -f /groups/umcg-gaf/tmp05/Samplesheets/${PROJECTNAME}_Check.txt ]
then
	COUNT=$(cat /groups/umcg-gaf/tmp05/Samplesheets/${PROJECTNAME}_Check.txt | wc -l)
	if [ $COUNT % 10 ]
	then
		### MAIL SOMEONE
		echo "MAIL SOMEONE"
	fi
fi
