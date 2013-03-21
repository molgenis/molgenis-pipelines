#
# =============================================================================
# BCL to FastQ conversion using Illumina's bcl2fastq convertor.
# =============================================================================
#

#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=06:00:00 nodes=1 cores=6 mem=12
#FOREACH run

#
# Bash sanity.
#
set -e
set -u

#
# Change permissions.
#
umask ${umask}

#
# Initialize script specific vars.
#
SCRIPTNAME=$(basename $0)

#
# Should I stay or should I go?
#
if [ -f "${bcl2fastqDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished" ]
then
    # Skip this job script.
	echo "${bcl2fastqDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished already exists: skipping BCL to FastQ conversion."
	exit 0
else
	rm -Rf ${bcl2fastqDir}_in_flux/
	mkdir -p ${bcl2fastqDir}_in_flux/
fi

#
# Create sample sheet in Illumina format based on our GAF sample sheets.
#
perl ${scriptsDir}/CreateIlluminaSampleSheet.pl \
-i ${McWorksheet} \
-o ${bcl2fastqDir}_in_flux/Illumina_R${run}.csv \
-r ${run}

#
# Configure BCL to FastQ conversion for this run. 
#
${bcl2fastqConfigureTool} \
--force \
--fastq-cluster-count 0 \
--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
--output-dir ${bcl2fastqDir}_in_flux/ \
--sample-sheet ${bcl2fastqDir}_in_flux/Illumina_R${run}.csv

#
# Convert the BCLs to FastQs.
#
cd ${bcl2fastqDir}_in_flux/
make -j 6

#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${bcl2fastqDir}{_in_flux,}
sync
touch ${bcl2fastqDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished
sync
