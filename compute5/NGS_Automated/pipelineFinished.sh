set -e
set -u

groupname=$1
MYINSTALLATIONDIR=$( cd -P "$( dirname "$0" )" && pwd )

##source config file (zinc-finger.gcc.rug.nl.cfg, leucine-zipper.gcc.rug.nl OR gattaca.cfg)
myhost=$(hostname)
. ${MYINSTALLATIONDIR}/${groupname}.cfg
. ${MYINSTALLATIONDIR}/${myhost}.cfg
. ${MYINSTALLATIONDIR}/sharedConfig.cfg

ALLFINISHED=()
ls ${LOGDIR}/*.pipeline.finished > ${LOGDIR}/AllProjects.pipeline.finished.csv
while read line 
do
	ALLFINISHED+=("${line} ")
done<${LOGDIR}/AllProjects.pipeline.finished.csv


for i in ${ALLFINISHED[@]}
do
	filename=$(basename $i)
	projectName="${filename%%.*}"
	if [ ! -d ${LOGDIR}/${projectName}/ ]
	then
		mkdir -p ${LOGDIR}/${projectName}/
		for i in $(ls ${PROJECTSDIR}/${projectName}/*/rawdata/ngs/*); do if [ -L $i ];then readlink $i > ${LOGDIR}/${projectName}.rawdatalink ; fi;done

		while read line ; do dirname $line > ${LOGDIR}/${projectName}.rawdatalinkDirName; done<${LOGDIR}/${projectName}.rawdatalink

		rawDataName=$(while read line ; do basename $line ; done<${LOGDIR}/${projectName}.rawdatalinkDirName)

		if [ -f ${LOGDIR}/${rawDataName}.pipeline.logger ]
		then
			mv ${LOGDIR}/${rawDataName}.pipeline.logger ${LOGDIR}/${rawDataName}/
		fi
		if [ -f ${LOGDIR}/${rawDataName}.scriptsGenerated ]
		then
			mv ${LOGDIR}/${rawDataName}.scriptsGenerated ${LOGDIR}/${rawDataName}/
		fi

		echo "moving ${projectName} files to ${LOGDIR}/${projectName}/ and removing tmp finished files"
		if [[ -f ${LOGDIR}/${projectName}.pipeline.logger  && -f ${LOGDIR}/${projectName}.pipeline.started && -f ${LOGDIR}/${projectName}.rawdatalink && -f ${LOGDIR}/${projectName}.rawdatalinkDirName ]]
		then 
			mv ${LOGDIR}/${projectName}.pipeline.logger ${LOGDIR}/${projectName}/
			rm ${LOGDIR}/${projectName}.pipeline.started
			rm ${LOGDIR}/${projectName}.rawdatalink
			rm ${LOGDIR}/${projectName}.rawdatalinkDirName
			touch ${LOGDIR}/${projectName}/${rawDataName}
		fi
		if [ -f ${LOGDIR}/${projectName}.pipeline.failed ]
		then
			mv ${LOGDIR}/${projectName}.pipeline.failed ${LOGDIR}/${projectName}/
		fi
	fi
	if [ ! -f ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed ]
	then
		printf "The results can be found: ${PROJECTSDIR}/${projectName} \n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${projectName} on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
		touch ${LOGDIR}/${projectName}/${projectName}.pipeline.finished.mailed
		rm ${LOGDIR}/${projectName}.pipeline.finished

	fi



done

