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

${EBROOTDELLY}/delly \
-n \
-t ${dellyType} \
-x human.hg19.excl.tsv \
-o ${tmpDellyVcf} \
-g ${indexFile} \
${dellyInput}

mv ${tmpDellyVcf} ${dellyVcf}
echo "moved ${tmpDellyVcf} to ${dellyVcf}"
