#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=05:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string peEnd1BarcodeFastQcZip
#string peEnd2BarcodeFastQcZip
#string srBarcodeFastQcZip
#string fastqcVersion

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQcZip: ${peEnd1BarcodeFastQcZip}"
echo "peEnd2BarcodeFastQcZip: ${peEnd2BarcodeFastQcZip}"
echo "srBarcodeFastQcZip: ${srBarcodeFastQcZip}"

#Load module
module load ${fastqcVersion}
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
	mv -f ${tmpIntermediateDir}/* ${intermediateDir}

else
	fastqc ${srBarcodeFqGz} \
	-o ${tmpIntermediateDir}

	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv -f ${tmpIntermediateDir}/* ${intermediateDir}
fi
