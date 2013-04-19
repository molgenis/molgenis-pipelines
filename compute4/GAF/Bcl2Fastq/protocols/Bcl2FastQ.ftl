#
# =============================================================================
# BCL to FastQ conversion using Illumina's bcl2fastq convertor.
# =============================================================================
#

#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=12:00:00 nodes=1 cores=6 mem=12
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
# Setup environmnet for tools we need.
#
module load bcl2fastq/${bcl2fastqVersion}
module list

#
# Initialize script specific vars.
#
RESULTDIR=<#if projectResultsDir?is_enumerable>${bcl2fastqDir[0]}<#else>${bcl2fastqDir}</#if>
SCRIPTNAME=${jobname}
FLUXDIR=<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>_in_flux/
<#assign fluxDir>${r"${FLUXDIR}"}</#assign>

#
# Should I stay or should I go?
#
if [ -f "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished" ]
then
    # Skip this job script.
	echo "<#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

#
# Create sample sheet in Illumina format based on our GAF sample sheets.
#
perl ${scriptsDir}/CreateIlluminaSampleSheet.pl \
-i ${McWorksheet} \
-o ${fluxDir}/Illumina_R${run}.csv \
-r ${run}

#
# Configure BCL to FastQ conversion for this run. 
#
configureBclToFastq.pl \
--force \
--fastq-cluster-count 0 \
--input-dir ${bclDir}/Data/Intensities/BaseCalls/ \
--output-dir ${fluxDir}/ \
--sample-sheet ${fluxDir}/Illumina_R${run}.csv

#
# Convert the BCLs to FastQs.
#
cd ${fluxDir}/
make -j 6

#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${fluxDir}/* <#noparse>${RESULTDIR}/</#noparse>
rmdir ${fluxDir}
sync
touch <#noparse>${RESULTDIR}/${SCRIPTNAME}</#noparse>.finished
sync
