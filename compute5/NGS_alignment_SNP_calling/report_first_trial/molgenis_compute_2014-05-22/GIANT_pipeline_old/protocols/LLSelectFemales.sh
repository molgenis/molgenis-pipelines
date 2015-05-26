#MOLGENIS walltime=01:00:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_originalFiles
#string stage
#string GIANT_tmpWorkDir
#string plink
#string GIANT_workDir_outputLiftoverDir

#Echo parameter values
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "stage: ${stage}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}" 
echo "plink: ${plink}"

if [ ! -d ${GIANT_tmpWorkDir}/LLSelectFemales ]
then
	mkdir -d ${GIANT_tmpWorkDir}/LLSelectFemales/
fi

#LL data: select only females  
${stage} ${plink}
plink --bfile ${GIANT_workDir_outputLiftoverDir}/chrX \
--filter-females \
--out ${GIANT_tmpWorkDir}/LLSelectFemales/chrX

perl -pi -e 's/^23/X/g' ${GIANT_tmpWorkDir}/LLSelectFemales/chrX.bim
