
#MOLGENIS walltime=00:45:00

module load GATK/${gatkVersion}
module list

inputs "${matefixedcovariatecsv}"
inputs "${sortedrecalcovariatecsv}"
alloutputsexist \
"${cyclecovariatebefore}" \
"${cyclecovariateafter}"

export PATH=${R_HOME}/bin:<#noparse>${PATH}</#noparse>
export R_LIBS=${R_LIBS} 

java -jar -Xmx4g ${analyzecovariatesjar} -l INFO \
-resources ${indexfile} \
--recal_file ${matefixedcovariatecsv} \
-outputDir ${recalstatsbeforedir} \
-Rscript ${rscript} \
-ignoreQ 5

java -jar -Xmx4g ${analyzecovariatesjar} -l INFO \
-resources ${indexfile} \
--recal_file ${sortedrecalcovariatecsv} \
-outputDir ${recalstatsafterdir} \
-Rscript ${rscript} \
-ignoreQ 5