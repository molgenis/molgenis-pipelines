#MOLGENIS nodes=1 ppn=1 mem=10gb walltime=05:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string intermediateDir
#string peEnd1BarcodeTrimmedFqGz
#string peEnd2BarcodeTrimmedFqGz
#string srBarcodeTrimmedFqGz
#string cutadaptVersion

#Load module
module load cutadapt/${cutadaptVersion}
module list

makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

makeTmpDir ${srBarcodeTrimmedFqGz}
tmpsrBarcodeTrimmedFqGz=${MC_tmpFile}

makeTmpDir ${peEnd1BarcodeTrimmedFqGz}
tmppeEnd1BarcodeTrimmedFqGz=${MC_tmpFile}

makeTmpDir ${peEnd2BarcodeTrimmedFqGz}
tmppeEnd2BarcodeTrimmedFqGz=${MC_tmpFile}


#If paired-end do cutadapt for both ends, else only for one
if [ ${seqType} == "PE" ]
then

	cutadapt \
        --cut=-50 \
        -o ${tmppeEnd1BarcodeTrimmedFqGz} \
	-p ${tmppeEnd2BarcodeTrimmedFqGz} \
	${peEnd1BarcodeFqGz} ${peEnd2BarcodeFqGz}	
	

	mv ${tmppeEnd1BarcodeTrimmedFqGz} ${peEnd1BarcodeTrimmedFqGz}
	mv ${tmppeEnd2BarcodeTrimmedFqGz} ${peEnd2BarcodeTrimmedFqGz}

	echo -e "\ncutadapt finished succesfull. Moving temp files to final.\n\n"

elif [ ${seqType} == "SR" ]
then
	cutadapt \
	--cut=-50 \
	-o ${tmpsrBarcodeTrimmedFqGz} \
	${srBarcodeFqGz}


	mv ${tmpsrBarcodeTrimmedFqGz} ${srBarcodeTrimmedFqGz}

	echo -e "\ncutadapt finished succesfull. Moving temp files to final.\n\n"
fi
