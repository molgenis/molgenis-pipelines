#MOLGENIS walltime=00:05:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_originalFiles
#string GIANT_tmpWorkDir
#string chrX_1000G_no_auto_phase1_refpanel
#string chrX_1000G_auto_phase1_refpanel
#string GIANT_workDir
#string GIANT_chrX_original
#string GIANT_chrX_original_tmp_name

#Echo parameter values
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}"
echo "GIANT_chrX_original: ${GIANT_chrX_original}"
echo "GIANT_chrX_original_tmp_name: ${GIANT_chrX_original_tmp_name}"

mkdir -p ${GIANT_tmpWorkDir}

mkdir -p ${GIANT_workDir_originalFiles}/referenceDir/auto
mkdir -p ${GIANT_workDir_originalFiles}/referenceDir/no_auto

#Copy chrX ped and map file to tmp directory to work with
cp ${GIANT_chrX_original}.ped ${GIANT_workDir_originalFiles}/${GIANT_chrX_original_tmp_name}.ped
echo 'copied:  ${GIANT_chrX_original}.ped ${GIANT_workDir_originalFiles}/${GIANT_chrX_original_tmp_name}.ped'

#Copy chrX ped and map file to tmp directory to work with
cp ${GIANT_chrX_original}.map ${GIANT_workDir_originalFiles}/${GIANT_chrX_original_tmp_name}.map
echo 'copied:  ${GIANT_chrX_original}.map ${GIANT_workDir_originalFiles}/${GIANT_chrX_original_tmp_name}.map'


cp ${chrX_1000G_no_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/referenceDir/no_auto
echo 'copied: ${chrX_1000G_no_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/referenceDir/no_auto'

cp ${chrX_1000G_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/referenceDir/auto
echo 'copied: ${chrX_1000G_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/referenceDir/auto'
