
##This is an example script to generate the pre rasqual jobs##

##This script replaces the $CHR variable in the parameter file##
##greatly improving generation time, since the additional -p ##
##parameter in the molgenis compute command isn't necessary ##
##anymore


#Convert parameter.csv for first iteration
sh convert.sh parametersPreRasqual.csv parametersPreRasqual.converted.csv


module load Molgenis-Compute/v16.11.1-Java-1.8.0_74

for i in {1..22}
do

###THE IMPORTANT PART###
#Replace CHR variable with proper number
perl -pi -e "s/^CHR,[0-9]{1,}/CHR,$i/gs" parametersPreRasqual.csv

#Convert parameter.csv
sh convert.sh parametersPreRasqual.csv parametersPreRasqual.converted.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
--backend slurm \
--generate \
-p parametersPreRasqual.converted.csv \
-p samplesheet_preRasqual.csv \
-w <PATH_TO_ASE_PIPELINE>/ASE/workflow_PreRasqual.csv \
-rundir ./jobs/preRasqual/chr$i/ \
--weave

done