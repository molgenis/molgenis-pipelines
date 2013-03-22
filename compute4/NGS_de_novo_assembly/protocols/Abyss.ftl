

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

<#noparse>
#module load abyss/${abyssVersion}
</#noparse>

<#noparse>
export PATH=/target/gpfs2/gcc/tools/ABySS/bin/:${PATH}
export PATH=/target/gpfs2/gcc/apps/openmpi-1.43/bin/:${PATH}
</#noparse>


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

alloutputsexist "${abyssContigs}"

# first make logdir...
mkdir -p -m 0770 "${assemblyResultDir}"

cd ${assemblyResultDir}

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
</#list>2>&1 | tee -a ${assemblyResultDir}/ABySS_k${kmer}_runtime.log

<#noparse>
# TODO: use putFile to move all output dir contents.
#putFile ${abyss_results}
</#noparse>
