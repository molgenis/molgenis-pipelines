#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=10:00:00 nodes=1 cores=1 mem=10

<#if seqType == "SR">
	# assume single read
	alloutputsexist ${leftbarcodefqgz}
	inputs ${leftbarcodefq}	
<#else>
	# assume paired end
	alloutputsexist ${leftbarcodefqgz} ${rightbarcodefqgz}
	inputs ${leftbarcodefq} ${rightbarcodefq}
</#if>

# The following code gzips files and removes original file
# However, in the case of a symlink, the symlink is removed.
	gzip -f ${leftbarcodefq}
<#if seqType == "PE">
	gzip -f ${rightbarcodefq}
</#if>