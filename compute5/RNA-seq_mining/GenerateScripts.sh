#!bin/bash

#main thing to remember when working with molgenis "/full/paths" ALWAYS!
#here some parameters for customisation
tmp="tmp01"
runDir=/gcc/groups/oncogenetics/${tmp}/projects/resourcesRNASeq/Workflow/runs/test
molgenisBase=/gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT


echo "Convert parametersheet"
perl $molgenisBase/workflows/RnaAnalysis/scripts/convertParametersGitToMolgenis.pl parameters.csv > parameters.molgenis.csv

echo "Generate scripts"
module load jdk/1.7.0_51

#runID=++

rm $runDir/*d

bash $molgenisBase/molgenis_compute.sh \
 --generate \
 -p $(pwd)/parameters.molgenis.csv \
 -p $(pwd)/samplesheet.csv \
 -w $(pwd)/workflow.csv \
 --backend pbs \
 --weave \
 -rundir $runDir \
 -runid 02 \
 -header $molgenisBase/templates/pbs/header.ftl \
 -submit $molgenisBase/templates/pbs/submit.ftl \
 -footer $molgenisBase/templates/pbs/footer.ftl 
