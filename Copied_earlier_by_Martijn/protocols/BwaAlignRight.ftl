#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

<#if seqType == "PE">
#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6
#TARGETS

module load bwa/${bwaVersion}

getFile ${indexfile}
getFile ${rightbarcodefqgz}
alloutputsexist "${rightbwaout}"

mkdir -p "${intermediatedir}"

bwa aln \
${indexfile} \
${rightbarcodefqgz} \
-t ${bwaaligncores} \
-f ${rightbwaout}

putFile ${rightbwaout}

</#if>