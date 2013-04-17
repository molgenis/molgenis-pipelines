#
# Initialize: resource usage requests + workflow control
#
#MOLGENIS walltime=18:00:00 nodes=1 cores=4 mem=40
#FOREACH project,sampleID,kmer,sampleID_kmer_combo

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
FLUXDIR=${assemblyResultDir}/<#noparse>${SCRIPTNAME}</#noparse>_in_flux/
<#assign fluxDir>${r"${FLUXDIR}"}</#assign>

#
# Should I stay or should I go?
#
if [ -f "${assemblyResultDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished" ]
then
    # Skip this job script.
	echo "${assemblyResultDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished already exists: skipping this job."
	exit 0
else
	rm -Rf ${fluxDir}
	mkdir -p -m 0770 ${fluxDir}
fi

module load ABySS/${abyssVersion}
module list

<#assign folded = foldParameters(parameters,"project,sampleID,kmer,library") />
<#assign libs = stringList(folded, "library") />
<#assign allreads_1 = stringList(folded, "fastq_1") />
<#assign allreads_2 = stringList(folded, "fastq_2") />

#
# Check if all required FastQ files are available for assembly.
#
<#list libs as thislib>
<#assign allreads_1_for_this_lib = "${allreads_1[thislib_index]}" />
<#assign allreads_2_for_this_lib = "${allreads_2[thislib_index]}" />
<#list "${allreads_1_for_this_lib}"?split(', ') as read1>
<#if "${read1}"?ends_with(']')>getFile ${read1?replace(']$', '', 'r')}
<#elseif "${read1}"?starts_with('[')>getFile ${read1?substring(1)}
</#if>
</#list>
<#list "${allreads_2_for_this_lib}"?split(', ') as read2>
<#if "${read2}"?ends_with(']')>getFile ${read2?replace(']$', '', 'r')}
<#elseif "${read2}"?starts_with('[')>getFile ${read2?substring(1)}
</#if>
</#list>
</#list>

cd ${fluxDir}

abyss-pe \
np=4 \
ABYSS_OPTIONS='--illumina-quality' \
q=20 \
k=${kmer} \
name=${assemblyResultPrefix} \
lib='${ssv(libs)}' \
mp='${ssv(libs)}' \
<#list libs as thislib>
<#assign allreads_1_for_this_lib = "${allreads_1[thislib_index]}" />
<#assign allreads_2_for_this_lib = "${allreads_2[thislib_index]}" />
${thislib}='<#list "${allreads_1_for_this_lib}"?split(',') as read1><#if "${read1}"?ends_with(']')>${read1?replace(']$', '', 'r')}<#elseif "${read1}"?starts_with('[')>${read1?substring(1)}</#if></#list> <#list "${allreads_2_for_this_lib}"?split(',') as read2><#if "${read2}"?ends_with(']')>${read2?replace(']$', '', 'r')}<#elseif "${read2}"?starts_with('[')>${read2?substring(1)}</#if></#list>' \
</#list>2>&1 | tee -a ${fluxDir}/ABySS.log

#
# We made it until here:
#  * Remove the _in_flux suffix.
#  * Flush disk caches to disk to make sure we don't loose any data 
#    when a machine crashes and some of the "written" data was in a write buffer.
#  * Write a *.finished file that prevents re-processing the data 
#    when this job script is re-submitted. 
#
mv ${fluxDir}/* ${assemblyResultDir}/
rmdir ${fluxDir}
sync
touch ${assemblyResultDir}/<#noparse>${SCRIPTNAME}</#noparse>.finished
sync

<#noparse>
# TODO: use putFile to move all output dir contents.
#putFile ${abyss_results}
</#noparse>
