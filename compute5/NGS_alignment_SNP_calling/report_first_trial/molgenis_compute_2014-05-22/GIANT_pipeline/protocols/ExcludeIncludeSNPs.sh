#MOLGENIS walltime=01:59:00 mem=4gb

#Parameter mapping
#string GIANT_tmpWorkDir
#string GIANT_workDir
#string plink
#string stage
#string GIANT_workDir_GH_Output_Dir
#string GIANT_workDir_outputLiftoverDir

#Echo parameter values
echo "GIANT_workDir_GH_Output_Dir: ${GIANT_workDir_GH_Output_Dir}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}"
echo "GIANT_workDir: ${GIANT_workDir}" 
echo "plink: ${plink}"
echo "GIANT_workDir_outputLiftoverDir: ${GIANT_workDir_outputLiftoverDir}"

${stage} ${plink}

#parse the Excluded and Swapped SNPs out of the snpLog.log file created by GenotypeHarmonizer

awk '{if($5=="Excluded"){print $3}}' ${GIANT_workDir_GH_Output_Dir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_Dir}/ExcludedSNPs.txt
awk '{if($5=="Swapped"){print $3}}' ${GIANT_workDir_GH_Output_Dir}/chrX_snpLog.log > ${GIANT_workDir_GH_Output_Dir}/SwappedSNPs.txt

#mkdir final result
mkdir -p ${GIANT_workDir}/finalResults

count=`grep ^23 ${GIANT_workDir_outputLiftoverDir}/chrX.bim | wc -l`

if [ $count -ne 0 ]
then
        echo "already converted to X"
else
        perl -pi -e 's/^X/23/g' ${GIANT_workDir_outputLiftoverDir}/chrX.bim
fi

#Run plink 
plink \
--bfile ${GIANT_workDir_outputLiftoverDir}/chrX \
--exclude ${GIANT_workDir_GH_Output_Dir}/ExcludedSNPs.txt \
--flip ${GIANT_workDir_GH_Output_Dir}/SwappedSNPs.txt \
--out ${GIANT_workDir}/finalResults/chrX \
--mind 0.995 \
--recode 

chmod -R 770 ${GIANT_workDir}/./
chmod -R 770 ${GIANT_tmpWorkDir}/./
