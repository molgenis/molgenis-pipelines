#MOLGENIS walltime=00:05:00 mem=4gb

#Parameter mapping
#string GIANT_workDir_originalFiles
#string GIANT_tmpWorkDir
#string chrX_1000G_no_auto_phase1_refpanel
#string chrX_1000G_auto_phase1_refpanel
#string chrX_1000G_sampleIDs_female_1000G_Name
#string chrX_1000G_sampleIDs_female_1000G
#string GIANT_workDir

#Echo parameter values
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}" 
echo "GIANT_tmpWorkDir: ${GIANT_tmpWorkDir}"
echo "chrX_1000G_sampleIDs_female_1000G: ${chrX_1000G_sampleIDs_female_1000G}"
echo "chrX_1000G_sampleIDs_female_1000G_Name: ${chrX_1000G_sampleIDs_female_1000G_Name}"


mkdir -p ${GIANT_tmpWorkDir}

mkdir -p ${GIANT_workDir_originalFiles}

#Copy chrX ped and map file to tmp directory to work with
cp /gcc/groups/lifelines/prm02/resources/UnimputedPedMap/output.chrX.* ${GIANT_workDir_originalFiles}
echo 'copied: /gcc/groups/lifelines/prm02/resources/UnimputedPedMap/output.chrX.* ${GIANT_workDir_originalFiles}'

cp ${chrX_1000G_no_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/${chrX_1000G_no_auto_phase1_refpanel_Name}
echo 'copied: ${chrX_1000G_no_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/${chrX_1000G_no_auto_phase1_refpanel_Name}'

cp ${chrX_1000G_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/${chrX_1000G_auto_phase1_refpanel_Name}
echo 'copied: ${chrX_1000G_auto_phase1_refpanel}* ${GIANT_workDir_originalFiles}/${chrX_1000G_auto_phase1_refpanel_Name}'

cp ${chrX_1000G_sampleIDs_female_1000G} ${GIANT_workDir_originalFiles}/${chrX_1000G_sampleIDs_female_1000G_Name}
echo 'cp ${chrX_1000G_sampleIDs_female_1000G} ${GIANT_workDir_originalFiles}/${chrX_1000G_sampleIDs_female_1000G_Name}'
