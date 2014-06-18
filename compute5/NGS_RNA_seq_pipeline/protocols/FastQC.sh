#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=03:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string peEnd1BarcodeFastQcZip
#string peEnd2BarcodeFastQcZip
#string srBarcodeFastQcZip

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQcZip: ${peEnd1BarcodeFastQcZip}"
echo "peEnd2BarcodeFastQcZip: ${peEnd2BarcodeFastQcZip}"
echo "srBarcodeFastQcZip: ${srBarcodeFastQcZip}"

sleep 10

#If paired-end then copy 2 files, else only 1
if [ ${seqType} == "PE" ]
then
        alloutputsexist \
        "${peEnd1BarcodeFastQcZip}" \
        "${peEnd2BarcodeFastQcZip}"
        
	getFile ${peEnd1BarcodeFqGz}
	getFile ${peEnd2BarcodeFqGz}

else
        alloutputsexist \
        "${srBarcodeFastQcZip}"
        
	getFile ${srBarcodeFqGz}

fi

#Load module
module load fastqc/v0.10.1
module list
makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	# end1 & end2
	fastqc ${peEnd1BarcodeFqGz} \
	${peEnd2BarcodeFqGz} \
	-o ${tmpIntermediateDir}
	
	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${peEnd1BarcodeFastQcZip}"
        putFile "${peEnd2BarcodeFastQcZip}"

else
	fastqc ${srBarcodeFqGz} \
	-o ${tmpIntermediateDir}

	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${srBarcodeFastQcZip}"
fi
