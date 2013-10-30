#MOLGENIS walltime=10:00:00 nodes=1 cores=1 mem=4

sortedBam="${sortedBam}"
python27="${python27}"
calculateGCscript="${calculateGCscript}"
GCcontent="${GCcontent}"

<#noparse>

echo "sortedBam=${sortedBam}"

alloutputsexist ${GCcontent}

${python27} ${calculateGCscript} \
${sortedBam} \
> ${GCcontent}

returnCode=$?
echo "Return code: ${returnCode}"

</#noparse>
