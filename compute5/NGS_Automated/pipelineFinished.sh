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
ls ${LOGDIR}/*.pipeline.finished > ${LOGDIR}/pipeline.finished.csv
while read line 
do
	ALLFINISHED+=("${line} ")
done<${LOGDIR}/pipeline.finished.csv

for i in ${ALLFINISHED[@]}
do
	filename=$(basename $i)
	projectName="${filename%%.*}"
	if [ ! -f ${LOGDIR}/${projectName}.pipeline.finished.mailed ]
	then
		"The results can be found: ${PROJECTSDIR}/${projectName} \n\nCheers from the GCC :)"| mail -s "NGS_DNA pipeline is finished for project ${projectName} on `date +%d/%m/%Y` `date +%H:%M`" ${ONTVANGER}
		touch ${LOGDIR}/${projectName}.pipeline.finished.mailed
	fi
done

