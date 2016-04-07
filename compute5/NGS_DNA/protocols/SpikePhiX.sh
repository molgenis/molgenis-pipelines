#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=12:30:00

#Parameter mapping
#string tmpName
#string seqType
#string phiXEnd1Gz
#string phiXEnd2Gz
#string srBarcodeFqGz
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string project
#string logsDir

sleep 10 

# Spike phiX only once
samp=`tail -10 ${peEnd1BarcodeFqGz}`
phiX=`tail -10 ${phiXEnd1Gz}`

if [ "$samp" = "$phiX" ]; 
then
	echo "Skip this step! PhiX was already spiked in!"
	exit 0
else
	if [ "${seqType}" == "SR" ]
	then
		echo "Spike phiX not implemented yet for Single Read"
		exit 1
	elif [ "${seqType}" == "PE" ]
	then
		echo "Append phiX reads"
		cat ${peEnd1BarcodeFqGz} ${phiXEnd1Gz} > ${peEnd1BarcodeFqGz}.tmp
		cat ${peEnd2BarcodeFqGz} ${phiXEnd2Gz} > ${peEnd2BarcodeFqGz}.tmp
		mv ${peEnd1BarcodeFqGz}.tmp ${peEnd1BarcodeFqGz}
		mv ${peEnd2BarcodeFqGz}.tmp ${peEnd2BarcodeFqGz}
	fi
fi
