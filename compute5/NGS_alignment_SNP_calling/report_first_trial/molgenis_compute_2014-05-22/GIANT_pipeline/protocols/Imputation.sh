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

python $IMPUTATION_HOME/molgenis-impute.py \
--study /gcc/groups/gcc/tmp01/rkanninga/imputation/phasing2/male \
--output /gcc/groups/gcc/tmp01/rkanninga/imputation/imputation/male \
--reference_dir /gcc/groups/gcc/tmp01/rkanninga/tmp/imputationReference/ \
--reference GIANTchrX \
--chromosomes X \
--backend pbs \
--action impute \
--nosubmit
