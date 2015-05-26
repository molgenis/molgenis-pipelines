#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=00:30:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string phiXEnd1Gz
#string phiXEnd2Gz
#string project

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"


# Spike phiX only once
samp=`tail -10 ${peEnd1BarcodeFqGz}`
phiX=`tail -10 ${phiXEnd1Gz}`

if [ "$samp" = "$phiX" ]; then
    echo "Skip this step! PhiX was already spiked in!"
	exit 0
else
	if [ ${seqType} == "SR" ]
	then
		echo "Spike phiX not implemented yet for Single Read"
		exit 1
	elif [ $seqType == "PE" ]
	    echo "Append phiX reads"
		zcat ${peEnd1BarcodeFqGz} ${phiXEnd1Gz} > ${peEnd1BarcodeFqGz}
		zcat ${peEnd2BarcodeFqGz} ${phiXEnd2Gz} > ${peEnd2BarcodeFqGz}
	fi
fi