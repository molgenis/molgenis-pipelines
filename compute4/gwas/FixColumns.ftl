#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=00:10:00
#FOREACH project

#
# Change permissions.
#
umask 0007

#
# Create project dirs.
#
mkdir -p ${projectRawDataDir}
mkdir -p ${projectJobsDir}
mkdir -p ${projectLogsDir}
mkdir -p ${projectIntermediateDir}
mkdir -p ${projectResultsDir}

<#if familyIDs?exists>
	${plink} --noweb --silent \
	--bfile ${plinkFileRaw} \
	--update-ids ${familyIDs} \
	--make-bed --out ${plinkFileFixedFamilies}
<#else>
	ln -s ${plinkFileRaw} ${plinkFileFixedFamilies}
</#if>

<#if parentIDs?exists>
	${plink} --noweb --silent \
	--bfile ${plinkFileFixedFamilies} \
	--update-parents ${parentIDs} \
	--make-bed --out ${plinkFileFixedParents}
<#else>
	ln -s ${plinkFileFixedFamilies} ${plinkFileFixedParents}
</#if>

<#if removeIDs?exists>
	${plink} --noweb --silent \
	--bfile ${plinkFileFixedParents} \
	--remove ${removeIDs} \
	--make-bed --out ${plinkFileClean}
<#else>
	ln -s  ${plinkFileFixedParents} ${plinkFileClean}
</#if>