#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=08:00:00 nodes=1 cores=1 mem=1
#TARGETS

<#if seqType == "SR">
     getFile ${srbarcodefqgz}
	 alloutputsexist \
	 "${leftfastqczip}"
<#else>
    getFile "${leftbarcodefqgz}"
    getFile "${rightbarcodefqgz}"
	alloutputsexist \
	 "${leftfastqczip}" \
	 "${rightfastqczip}"
</#if>

# first make logdir...
mkdir -p "${intermediatedir}"

# pair1
${fastqcbin} \
${leftbarcodefqgz} \
-o ${intermediatedir}

<#if seqType == "PE">
# pair2
${fastqcbin} \
${rightbarcodefqgz} \
-o ${intermediatedir}

</#if>

<#if seqType == "SR">
      putFile ${leftfastqczip}
<#else>
      putFile ${leftfastqczip}
      putFile ${rightfastqczip}
</#if>