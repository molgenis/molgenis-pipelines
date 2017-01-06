########################################################
###To prevent issues with folding time, eg. when using >20 samples, job generation for the Rasqual step needs to be done separately.
###To do so one must generate jobs in multiple steps "two-step rocket".
###Please follow the three commands below
########################################################



######NOTE########NOTE#######NOTE##########NOTE#########
### This example only works for Meta-exon chunks if
### needed change the chunks *.csv file in the -p para-
### meter in STEP2 and STEP3
######NOTE########NOTE#######NOTE##########NOTE#########



##PRE-PROCESSING
#First chunk the Meta-exon file per chromosome, which is needed as input in STEP2 and STEP3

for i in {1..22}; do head -1 chromosomeMetaExonChunks.csv > chromosomeMetaExonChunks.chr$i.csv; grep "^$i," chromosomeMetaExonChunks.csv >> chromosomeMetaExonChunks.chr$i.csv; done



##STEP1## Generate all jobs up to Rasqual step

sh convert.sh parameter_files/parametersPreRasqual.csv parameter_files/parametersPreRasqual.converted.csv

module load Molgenis-Compute/v16.05.1-Java-1.8.0_45

#Please use --header /your/header/here.ftl to use your own job header
sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
--backend slurm \
--generate \
-p parameter_files/parametersPreRasqual.converted.csv \
-p samplesheet.csv \
-w workflow_PreRasqual.csv \
-p chromosomes_noSex.csv \
-rundir ./jobs/preRasqual/ \
--weave



##STEP2## Generate all Rasqual jobs per chromosome and write per chromosome to job folder

sh convert.sh parameter_files/parametersRasqual.csv parameter_files/parametersRasqual.converted.csv

module load Molgenis-Compute/v16.05.1-Java-1.8.0_45

for i in {1..22}
do

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
--backend slurm \
--generate \
-p parameter_files/parametersRasqual.converted.csv \
-w workflow_Rasqual.csv \
-p chromosomeMetaExonChunks.chr$i.csv \
-rundir ./jobs/rasqual/chr$i/ \
--weave

done



##STEP3## Generate merge Rasqual result jobs

sh convert.sh parameter_files/parametersRasqual.csv parameter_files/parametersRasqual.converted.csv

module load Molgenis-Compute/v16.05.1-Java-1.8.0_45

for i in {1..22}
do


sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
--backend slurm \
--generate \
-p parameter_files/parametersRasqual.converted.csv \
-p samplesheet.csv \
-w workflow_MergeRasqual.csv \
-p chromosomeMetaExonChunks.chr$i.csv \
-rundir ./jobs/mergeRasqual/chr$i/ \
--weave

done