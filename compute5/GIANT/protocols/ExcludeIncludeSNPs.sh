#MOLGENIS walltime=01:59:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_GH_Output_no_autoDir
#string GIANT_workDir_GH_Output_autoDir
#string GIANT_tmpWorkDir
#string GIANT_workDir
#string GIANT_workDir_originalFiles
#string plink
#string stage

#Echo parameter values
echo "GIANT_workDir_GH_Output_no_autoDir: ${GIANT_workDir_GH_Output_no_autoDir}" 
echo "GIANT_workDir_GH_Output_autoDir: ${GIANT_workDir_GH_Output_autoDir}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}"
echo "GIANT_workDir: ${GIANT_workDir}" 
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "plink: ${plink}"

${stage} ${plink}

#parse the Excluded and Swapped SNPs out of the snpLog.log file created by GenotypeHarmonizer
#auto
awk '{if($5=="Excluded"){print $3}}' ${GIANT_workDir_GH_Output_autoDir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_autoDir}/ExcludedSNPs.txt
awk '{if($5=="Swapped"){print $3}}' ${GIANT_workDir_GH_Output_autoDir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_autoDir}/SwappedSNPs.txt

#no_auto
awk '{if($5=="Excluded"){print $3}}' ${GIANT_workDir_GH_Output_no_autoDir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_no_autoDir}/ExcludedSNPs.txt
awk '{if($5=="Swapped"){print $3}}' ${GIANT_workDir_GH_Output_no_autoDir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_no_autoDir}/SwappedSNPs.txt


#merge ExcludedSNPs and SwappedSNPs files from both auto and no_auto
cat ${GIANT_workDir_GH_Output_no_autoDir}/ExcludedSNPs.txt  ${GIANT_workDir_GH_Output_autoDir}/ExcludedSNPs.txt > ${GIANT_tmpWorkDir}/ExcludedSNPs_both.txt
cat ${GIANT_workDir_GH_Output_no_autoDir}/SwappedSNPs.txt  ${GIANT_workDir_GH_Output_autoDir}/SwappedSNPs.txt > ${GIANT_tmpWorkDir}/SwappedSNPs_both.txt

#mkdir final result
mkdir -p ${GIANT_workDir}/finalResults

#Run plink 
plink \
--file ${GIANT_workDir_originalFiles}/output.chrX \
--exclude ${GIANT_tmpWorkDir}/ExcludedSNPs_both.txt \
--flip ${GIANT_tmpWorkDir}/SwappedSNPs_both.txt \
--out ${GIANT_workDir}/finalResults/Male_and_Female_recoded \
--recode 

chmod -R 770 ${GIANT_workDir}/./
chmod -R 770 ${GIANT_tmpWorkDir}/./
