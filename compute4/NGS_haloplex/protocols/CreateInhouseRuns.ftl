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
#FOREACH run, flowcell

#
# Change permissions.
#
umask 0007

#
# Create run dirs.
#
mkdir -p ${runJobsDir}
mkdir -p ${runResultsDir}

#
# Create subset of samples for this project.
#
<#--<#assign unfolded = unfoldParametersCSV(parameters) />
<#list unfolded as sampleSequenceDetails>
echo ${sampleSequenceDetails} >> ${runJobsDir}/${run}.csv
</#list>-->
${scriptdir}/extract_samples_from_GAF_list.pl --i ${McWorksheet} --o ${runJobsDir}/${run}.csv --c run --q ${run}

#
# Execute MOLGENIS/compute to create job scripts to analyse this project.
#
sh ${McDir}/molgenis_compute.sh \
-worksheet=${runJobsDir}/${run}.csv \
-parameters=${McParameters} \
-workflow=${demultiplexWorkflowFile} \
-protocols=${McProtocols}/ \
-templates=${McTemplates}/ \
-scripts=${runJobsDir}/ \
-id=${McId}