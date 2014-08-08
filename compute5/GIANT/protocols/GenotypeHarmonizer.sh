#MOLGENIS walltime=01:59:00 mem=4gb ppn=4

#Parameter mapping
#string GIANT_workDir_GH_OutputDir
#string chrX_1000G_phase1_refpanel_female_only_recode
#string GIANT_workDir_outputLiftoverDir
#string stage

#Echo parameter values
echo "GIANT_workDir_GH_OutputDir: ${GIANT_workDir_GH_OutputDir}" 
echo "chrX_1000G_phase1_refpanel_female_only_recode: ${chrX_1000G_phase1_refpanel_female_only_recode}" 
echo "GIANT_workDir_outputLiftoverDir: ${GIANT_workDir_outputLiftoverDir}" 
echo "stage: ${stage}"

if [ ! -d ${GIANT_workDir_GH_OutputDir} ]
then
	mkdir ${GIANT_workDir_GH_OutputDir}
fi

${stage} GenotypeHarmonizer
java -jar ${GENOTYPEHARMONIZER_HOME}/GenotypeHarmonizer.jar -XX:ParallelGCThreads=4 --inputType PLINK_BED \
--input ${GIANT_workDir_outputLiftoverDir}/chrX \
--output ${GIANT_workDir_GH_OutputDir}/chrX \
--ref ${chrX_1000G_phase1_refpanel_female_only_recode}.recode.vcf.gz
