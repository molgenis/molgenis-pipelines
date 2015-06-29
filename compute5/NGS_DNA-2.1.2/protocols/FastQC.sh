#MOLGENIS ppn=3 mem=3gb walltime=03:00:00

#Parameter mapping
#string seqType
#string peEnd1BarcodeFqGz
#string peEnd2BarcodeFqGz
#string srBarcodeFqGz
#string stage
#string checkStage
#string fastqcVersion
#string intermediateDir
#string peEnd1BarcodeFastQc
#string peEnd2BarcodeFastQc
#string srBarcodeFastQc
#string tmpDataDir
#string project

#Echo parameter values
echo "seqType: ${seqType}"
echo "peEnd1BarcodeFqGz: ${peEnd1BarcodeFqGz}"
echo "peEnd2BarcodeFqGz: ${peEnd2BarcodeFqGz}"
echo "srBarcodeFqGz: ${srBarcodeFqGz}"
echo "stage: ${stage}"
echo "checkStage: ${checkStage}"
echo "fastqcVersion: ${fastqcVersion}"
echo "intermediateDir: ${intermediateDir}"
echo "peEnd1BarcodeFastQc: ${peEnd1BarcodeFastQc}"
echo "peEnd2BarcodeFastQc: ${peEnd2BarcodeFastQc}"
echo "srBarcodeFastQc: ${srBarcodeFastQc}"

sleep 10

#Load module
${stage} fastqc/${fastqcVersion}
${checkStage}
makeTmpDir ${intermediateDir}
tmpIntermediateDir=${MC_tmpFile}

#If paired-end do fastqc for both ends, else only for one
if [ ${seqType} == "PE" ]
then
	fastqc ${peEnd1BarcodeFqGz} \
	${peEnd2BarcodeFqGz} \
	-o ${tmpIntermediateDir}
	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	rsync -a ${tmpIntermediateDir} ${intermediateDir}
	rm -rf ${tmpIntermediateDir}
else
	fastqc ${srBarcodeFqGz} \
	-o ${tmpIntermediateDir}
	echo -e "\nFastQC finished succesfull. Moving temp files to final.\n\n"
	rsync -a ${tmpIntermediateDir} ${intermediateDir}
	rm -rf ${tmpIntermediateDir}
fi


