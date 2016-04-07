#MOLGENIS walltime=120:00:00 mem=30gb
#string tmpName
#string project
#string logsDir
#string indexFile
#string intermediateDir
#string dellyVersion
#string dellyType
#string dellyInput
#string dellyVcf
#string GCC_Analysis

module load delly/${dellyVersion}
module list

makeTmpDir ${dellyVcf}
tmpDellyVcf=${MC_tmpFile}

if [ "${GCC_Analysis}" == "diagnostiek" ] || [ "${GCC_Analysis}" == "diagnostics" ] || [ "${GCC_Analysis}" == "Diagnostiek" ] || [ "${GCC_Analysis}" == "Diagnostics" ]
then
	echo "Delly step is skipped"
else
	${EBROOTDELLY}/delly \
	-n \
	-t ${dellyType} \
	-x human.hg19.excl.tsv \
	-o ${tmpDellyVcf} \
	-g ${indexFile} \
	${dellyInput}

	mv ${tmpDellyVcf} ${dellyVcf}
	echo "moved ${tmpDellyVcf} to ${dellyVcf}"
fi
