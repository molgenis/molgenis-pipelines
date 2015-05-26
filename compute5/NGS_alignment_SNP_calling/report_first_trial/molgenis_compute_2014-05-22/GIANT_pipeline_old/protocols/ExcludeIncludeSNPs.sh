#MOLGENIS walltime=01:59:00 mem=4gb

#Parameter mapping
#string GIANT_tmpWorkDir
#string GIANT_workDir
#string plink
#string stage
#string GIANT_workDir_GH_Output_Dir

#Echo parameter values
echo "GIANT_workDir_GH_Output_Dir: ${GIANT_workDir_GH_Output_Dir}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}"
echo "GIANT_workDir: ${GIANT_workDir}" 
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "plink: ${plink}"

${stage} ${plink}

#parse the Excluded and Swapped SNPs out of the snpLog.log file created by GenotypeHarmonizer

awk '{if($5=="Excluded"){print $3}}' ${GIANT_workDir_GH_Output_Dir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_Dir}/ExcludedSNPs.txt
awk '{if($5=="Swapped"){print $3}}' ${GIANT_workDir_GH_Output_Dir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_Dir}/SwappedSNPs.txt

#mkdir final result
mkdir -p ${GIANT_workDir}/finalResults

#Run plink 
plink \
--bfile ${GIANT_tmpWorkDir}/LLFemale/chrX \
--exclude ${GIANT_workDir_GH_Output_Dir}/ExcludedSNPs.txt \
--flip ${GIANT_workDir_GH_Output_Dir}/SwappedSNPs.txt \
--out ${GIANT_workDir}/finalResults_2/chrX \
--mind 0.995 \
--recode 

chmod -R 770 ${GIANT_workDir}/./
chmod -R 770 ${GIANT_tmpWorkDir}/./
