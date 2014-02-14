#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=23:59:00
#TARGETS

module load bwa/${bwaVersion}

getFile ${indexfile}
getFile ${leftbwaout}
getFile ${rightbwaout}
getFile ${leftbarcodefqgz}
getFile ${rightbarcodefqgz}
alloutputsexist "${samfile}"

<#if seqType == "PE">bwa sampe -P \<#else>bwa samse \</#if>
-p illumina \
-i ${lane} \
-m ${externalSampleID} \
-l ${library} \
${indexfile} \
${leftbwaout} \
<#if seqType == "PE">${rightbwaout} \
</#if>${leftbarcodefqgz} \
<#if seqType == "PE">${rightbarcodefqgz} \
</#if>-f ${samfile}

putFile ${samfile}