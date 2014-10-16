#MOLGENIS nodes=1 ppn=4 mem=8gb walltime=23:59:00

#Parameter mapping
#string reads2FqGz
#string stage
#string checkStage
#string fluxcapacitorVersion
#string indelRealignmentBam
#string indelRealignmentBai
#string sampleName

#string fluxcapacitorDir
#string fluxcapacitorGTF
#string fluxcapacitorExpressionGTF

echo "## "$(date)" ##  $0 Started "

alloutputsexist \
 ${fluxcapacitorExpressionGTF}

${stage} flux-capacitor/${fluxcapacitorVersion}
${checkStage}

getFile ${fluxcapacitorGTF}
getFile ${indelRealignmentBam}
getFile ${indelRealignmentBai}

#psuedo flux-capacitor -force --disable-file-check --coverage-file <COVERAGE_FILE> --keep-sorted MAPPING_FILE --keep-sorted ANNOTATION_FILE -a Homo_sapiens.GRCh37.75.fluxcapacitor.sorted.gtf -i in.bam -o flux.expression.gtf --count-elements SPLICE_JUNCTIONS??

mkdir -p ${fluxcapacitorDir}

export FLUX_MEM="8G";

if [ ${#reads2FqGz} -eq 0 ]; then
	readDescriptor="SIMPLE"
else
	readDescriptor="PAIRED"
fi

#commandline:flux-capacitor --force -a /gcc//groups/oncogenetics/tmp01/resources/b37/intervals/Homo_sapiens.GRCh37.75.fluxcapacitor.sorted.gtf -i /gcc/groups/oncogenetics/tmp01/projects/test2//indelRealignment/samplePE.bam -o /gcc/groups/oncogenetics/tmp01/projects/test2//fluxcapacitor//samplePE.GRCh37.75.fluxcapacitor.sorted.gtf -m PAIRED --coverage-file /gcc/groups/oncogenetics/tmp01/projects/test2//fluxcapacitor//samplePE.GRCh37.75.fluxcapacitor.sorted.gtf.coverage.flux --stats-file /gcc/groups/oncogenetics/tmp01/projects/test2//fluxcapacitor//samplePE.GRCh37.75.fluxcapacitor.sorted.gtf.stats.log --tmp-dir /gcc/groups/oncogenetics/tmp01/projects/test2//fluxcapacitor/  --keep-sorted MAPPING_FILE --threads 4 --disable-file-check

flux-capacitor \
 --force \
 -a ${fluxcapacitorGTF} \
 -i ${indelRealignmentBam} \
 -m $readDescriptor \
 -r \
 --tmp-dir ${fluxcapacitorDir} \
 --keep-sorted MAPPING_FILE \
 --threads 4 \
 --disable-file-check |
perl \
 -wpe 's/; reads /; '${sampleName}'.reads /; s/; RPKM /; '${sampleName}'.RPKM /' > ${fluxcapacitorExpressionGTF}

putFile ${fluxcapacitorExpressionGTF}

echo "## "$(date)" ##  $0 Done "

