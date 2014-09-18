#
# =====================================================
# $Id$
# $URL$
# $LastChangedDate$
# $LastChangedRevision$
# $LastChangedBy$
# =====================================================
#

#MOLGENIS walltime=33:00:00 nodes=1 cores=4 mem=4
#FOREACH externalSampleID

inputs "${mergedbam}"
inputs "${indexfile}"
alloutputsexist \
"${pindelOutput}_BP" \
"${pindelOutput}_CloseEndMapped" \
"${pindelOutput}_D" \
"${pindelOutput}_INV" \
"${pindelOutput}_LI" \
"${pindelOutput}_SI" \
"${pindelOutput}_TD" \
"${pindelOutput}_MERGED" \
"${pindelOutputVcf}"


#Create pindel config file
echo "${mergedbam} ${targetedinsertsize} ${externalSampleID}" \
> ${pindelcnfgfile}

#Run pindel on all chromosomes
${pindelBin} \
-f ${indexfile} \
-i ${pindelcnfgfile} \
-c ALL \
-T ${pindelCores} \
-o ${pindelOutput}

#Cat outputs together. Pindel produces more output for other sorts of SVs,
#these can't be converted to VCF yet, so are not merged.
cat ${pindelOutput}_CloseEndMapped \
${pindelOutput}_D \
${pindelOutput}_INV \
${pindelOutput}_SI \
${pindelOutput}_TD \
> ${pindelOutput}_MERGED

#Get current date
DATE=`date | awk '{print $6,$2,$3}' OFS="_"`

#Convert pindel output to VCF and use GATK annotation as output
${pindel2VcfBin} \
-p ${pindelOutput}_MERGED \
-r ${indexfile} \
-R ${indexfileIDtest} \
-d $DATE \
--gatk_compatible \
-v ${pindelOutputVcf}
