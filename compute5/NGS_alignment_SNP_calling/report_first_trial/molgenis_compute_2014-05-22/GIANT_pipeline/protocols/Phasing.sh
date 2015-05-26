
#MOLGENIS walltime=32:00:00 mem=4gb

#Parameter mapping
#string GIANT_workDir
#string stage
#string GIANT_workDir_originalFiles
#string pseudo

echo "GIANT_workDir: ${GIANT_workDir}"
echo "$GIANT_workDir_originalFiles: {GIANT_workDir_originalFiles}"
echo "pseudo: ${pseudo}"


${stage} molgenis_compute/v5_20140522
${stage} anaconda
${stage} imputation

imputationDir=${GIANT_workDir}/imputation-tools/

mkdir -p ${imputationDir}/resources/genetic_map/

cp -r $IMPUTATION_HOME/molgenis_imputation/tools ${imputationDir}
cp -r $IMPUTATION_HOME/molgenis_imputation/molgenis-compute ${imputationDir}
cp /gcc/resources/imputation/genetic_map_chrX_combined_b37.txt ${imputationDir}/resources/genetic_map/
sudo -u envsync /gcc/tools/scripts/gcc_sync.bash  -r imputation/

python $IMPUTATION_HOME/molgenis-impute.py \
--study ${GIANT_workDir}/finalResults/ \
--chromosomes X \
--installation_dir ${imputationDir} \
--reference_dir ${GIANT_workDir_originalFiles}/reference/ \
--reference ${pseudo} \
--backend pbs \
--nosubmit \
--action phase \
--output ${GIANT_workDir}/phasing 

phaseDir=`ls ${imputationDir}/generated`

#go to phasing directory 
cd ${imputationDir}/generated/${phaseDir}
sh submit.sh
