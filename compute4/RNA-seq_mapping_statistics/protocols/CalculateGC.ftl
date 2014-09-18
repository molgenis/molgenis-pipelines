#MOLGENIS walltime=10:00:00 nodes=1 cores=1 mem=4

sortedBam="${sortedBam}"
calculateGCscript="${calculateGCscript}"
GCcontent="${GCcontent}"

<#noparse>

module load python/2.7.5

echo "sortedBam=${sortedBam}"

alloutputsexist ${GCcontent}

python ${calculateGCscript} \
${sortedBam} \
> ${GCcontent}

returnCode=$?
echo "Return code: ${returnCode}"

</#noparse>
