#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=48:00:00 mem=10 cores=8
#FOREACH run

#Source GAF bash
. ${gafhome}/gaf.bashrc

${configureBclToFastq} \
--force \
--fastq-cluster-count 0 \
--input-dir ${baseCallDir} \
--output-dir ${bclToFastqResultDir} \
--sample-sheet ${illuminaSampleSheet}

cd ${bclToFastqResultDir}
make -j 8

