#MOLGENIS walltime=01:00:00 mem=1gb ppn=2

#string inputDataTmp
#list externalSampleID
#string utrechtDir
umask 0007

if [ ! -d ${inputDataTmp} ]; then
    mkdir -m 770 -p ${inputDataTmp}
fi

#
# Copying data to location where it will be analysed.
#
for externalID in "${externalSampleID[@]}"; do
    rsync -av ${utrechtDir}/${externalID}/mapping/${externalID}_dedup.bam* ${inputDataTmp}
done

echo "rsync done"
