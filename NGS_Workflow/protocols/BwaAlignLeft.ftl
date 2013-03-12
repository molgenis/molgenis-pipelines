#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=15:00:00 nodes=1 cores=4 mem=6
#TARGETS

module load bwa/${bwaVersion}

getFile ${indexfile}
getFile ${leftbarcodefqgz}
alloutputsexist "${leftbwaout}"

mkdir -p "${intermediatedir}"

bwa aln \
${indexfile} \
${leftbarcodefqgz} \
-t ${bwaaligncores} \
-f ${leftbwaout}


putFile ${leftbwaout}