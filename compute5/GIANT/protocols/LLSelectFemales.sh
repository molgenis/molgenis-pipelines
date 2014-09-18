#MOLGENIS walltime=01:00:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_originalFiles
#string stage
#string GIANT_tmpWorkDir
#string plink

#Echo parameter values
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "stage: ${stage}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}" 
echo "plink: ${plink}"


#LL data, filtering on female
cat  ${GIANT_workDir_originalFiles}/output.chrX.ped | awk '$5 ==2{print $0}' >  ${GIANT_workDir_originalFiles}/output.chrX.ped.female_only.ped 

#LL data: make binary ped file  
${stage} ${plink}
plink --ped ${GIANT_workDir_originalFiles}/output.chrX.ped.female_only.ped \
--map ${GIANT_workDir_originalFiles}/output.chrX.map \
--make-bed \
--out ${GIANT_tmpWorkDir}/LifeLines_chrX.female_only
