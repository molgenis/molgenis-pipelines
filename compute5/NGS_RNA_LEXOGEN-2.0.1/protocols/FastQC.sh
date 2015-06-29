#MOLGENIS nodes=1 ppn=1 mem=1gb walltime=05:00:00


#Parameter mapping
#string seqType
#string peEnd1BarcodeTrimmedFqGz
#string peEnd2BarcodeTrimmedFqGz
#string srBarcodeTrimmedFqGz
#string intermediateDir
#string peEnd1BarcodeFastQcZip
#string peEnd2BarcodeFastQcZip
#string srBarcodeFastQcZip
#string fastqcVersion

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeTrimmedFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeTrimmedFqGz}"
echo "srBarcodeFqGz: ${srBarcodeTrimmedFqGz}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQcZip: ${peEnd1BarcodeFastQcZip}"
echo "peEnd2BarcodeFastQcZip: ${peEnd2BarcodeFastQcZip}"
echo "srBarcodeFastQcZip: ${srBarcodeFastQcZip}"

#Load module
module load fastqc/${fastqcVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	# end1 & end2
	fastqc ${peEnd1BarcodeTrimmedFqGz} \
	${peEnd2BarcodeTrimmedFqGz} \
	-o ${tmpIntermediateDir}
	
	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv -f ${tmpIntermediateDir}/* ${intermediateDir}
	putFile "${peEnd1BarcodeFastQcZip}"
        putFile "${peEnd2BarcodeFastQcZip}"

else
	fastqc ${srBarcodeTrimmedFqGz} \
	-o ${tmpIntermediateDir}

	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	mv -f ${tmpIntermediateDir}/* ${intermediateDir}
fi
