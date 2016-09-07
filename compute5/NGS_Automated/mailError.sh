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
if ls ${LOGDIR}/*.pipeline.failed 1> /dev/null 2>&1 
then
	ls ${LOGDIR}/*.pipeline.failed > ${LOGDIR}/pipeline.failed.csv
else
	exit 0
fi

while read line 
do
	ALLFAILED+=("${line} ")
done<${LOGDIR}/pipeline.failed.csv

for i in ${ALLFAILED[@]}
do
	filename=$(basename $i)
	projectName="${filename%%.*}"
	
	mailTo="helpdesk.gcc.groningen@gmail.com"
        if [ $groupname == "umcg-gaf" ]
        then
                mailTo="helpdesk.gcc.groningen@gmail.com"
        elif [ "${groupname}" == "umcg-gd" ]
        then
            	echo "mailTo is umcg-gd"
                if [ -f /groups/umcg-gd/${tmpDirectory}/logs/mailinglistDiagnostiek.txt ]
                then
                       	mailTo=$(cat /groups/umcg-gd/${tmpDirectory}/logs/mailinglistDiagnostiek.txt)
                else
                      	echo "mailingListDiagnostiek.txt bestaat niet!!"
                        exit 0
                fi
        fi
	
	if [ ! -f ${LOGDIR}/${projectName}.pipeline.failed.mailed ]
	then
		HEADER=$(head -1 ${LOGDIR}/${projectName}.pipeline.failed)
		cat ${LOGDIR}/${projectName}.pipeline.failed | mail -s "The NGS_DNA pipeline on $myhost has crashed for project ${projectName} on step ${HEADER}" ${mailTo}
		touch ${LOGDIR}/${projectName}.pipeline.failed.mailed
	fi
done
