#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=08:00:00 nodes=1 cores=1 mem=1
#FOREACH sequencingStartDate, sequencer, run, flowcell, lane, barcode

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
RESULTDIR=<#if projectResultsDir?is_enumerable>${projectResultsDir[0]}<#else>${projectResultsDir}</#if>
SCRIPTNAME=$(basename $0)
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

module load fastqc/${fastqcVersion}
module list

<#if seqType == "SR">
    getFile ${srbarcodefqgz[0]}
<#else>
    getFile "${leftbarcodefqgz[0]}"
    getFile "${rightbarcodefqgz[0]}"
</#if>

# pair1
fastqc ${leftbarcodefqgz[0]} \
-Djava.io.tmpdir=${tempdir} \
-Dfastqc.output_dir=${fluxDir} \
-Dfastqc.unzip=false

<#if seqType == "PE">
# pair2
fastqc ${rightbarcodefqgz[0]} \
-Djava.io.tmpdir=${tempdir} \
-Dfastqc.output_dir=${fluxDir} \
-Dfastqc.unzip=false
</#if>

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

<#if seqType == "SR">
      putFile ${leftfastqczip[0]}
      putFile ${leftfastqcsummarytxt[0]}
      putFile ${leftfastqcsummarylog[0]}
<#else>
      putFile ${leftfastqczip[0]}
      putFile ${leftfastqcsummarytxt[0]}
      putFile ${leftfastqcsummarylog[0]}
      putFile ${rightfastqczip[0]}
      putFile ${rightfastqcsummarytxt[0]}
      putFile ${rightfastqcsummarylog[0]}
</#if>