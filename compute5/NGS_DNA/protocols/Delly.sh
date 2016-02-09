#MOLGENIS walltime=63:59:00 mem=10gb
#string project
#string indexFile
#string intermediateDir
#string dellyVersion
#string dellyType
#string dellyInput
#string dellyVcf

module load delly/${dellyVersion}
module list

makeTmpDir ${dellyVcf}
tmpDellyVcf=${MC_tmpFile}

if [ "${GCC_Analysis}" == "diagnostiek" ] || [ "${GCC_Analysis}" == "diagnostics" ] || [ "${GCC_Analysis}" == "Diagnostiek" ] || [ "${GCC_Analysis}" == "Diagnostics" ]
then
	${EBROOTDELLY}/delly \
	-n \
	-t ${dellyType} \
	-x human.hg19.excl.tsv \
	-o ${tmpDellyVcf} \
	-g ${indexFile} \
	${dellyInput}

	mv ${tmpDellyVcf} ${dellyVcf}
	echo "moved ${tmpDellyVcf} to ${dellyVcf}"
else
	echo "Delly step is skipped"
fi
