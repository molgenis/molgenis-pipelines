#MOLGENIS walltime=01:59:00 mem=4gb ppn=4

set -e
set -u

#Parameter mapping
#string GIANT_workDir_GH_OutputDir
#string chrX_1000G_phase1_refpanel
#string GIANT_workDir_outputLiftoverDir
#string stage
#string GIANT_workDir_originalFiles
#string pseudo


#Echo parameter values
echo "GIANT_workDir_GH_OutputDir: ${GIANT_workDir_GH_OutputDir}" 
echo "chrX_1000G_phase1_refpanel: ${chrX_1000G_phase1_refpanel}" 
echo "GIANT_workDir_outputLiftoverDir: ${GIANT_workDir_outputLiftoverDir}" 
echo "stage: ${stage}"
echo "GIANT_workDir_originalFiles: ${GIANT_workDir_originalFiles}"
echo "pseudo: ${pseudo}"

if [ ! -d ${GIANT_workDir_GH_OutputDir} ]
then
	mkdir ${GIANT_workDir_GH_OutputDir}
fi

count=`grep ^X ${GIANT_workDir_outputLiftoverDir}/chrX.bim | wc -l`

if [ $count -ne 0 ]
then
        echo "already converted to X"
else
	perl -pi -e 's/^23/X/g' ${GIANT_workDir_outputLiftoverDir}/chrX.bim	
fi

${stage} GenotypeHarmonizer
java -jar -XX:ParallelGCThreads=4 ${GENOTYPEHARMONIZER_HOME}/GenotypeHarmonizer.jar --inputType PLINK_BED \
--input ${GIANT_workDir_outputLiftoverDir}/chrX \
--output ${GIANT_workDir_GH_OutputDir}/chrX \
--ref ${GIANT_workDir_originalFiles}/reference/${pseudo}/${chrX_1000G_phase1_refpanel}.vcf.gz

