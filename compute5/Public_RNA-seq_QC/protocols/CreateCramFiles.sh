#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=08:00:00

### variables to help adding to database (have to use weave)
#string internalId
#string sampleName
#string project
###
#string stage
#string checkStage
#string picardVersion
#string iolibVersion
#string unfilteredBamDir
#string cramFileDir
#string tmpCramFileDir
#string onekgGenomeFasta
#string uniqueID


# Get input file

#Load modules
${stage} picard/${picardVersion}
${stage} io_lib/${iolibVersion}

#check modules
${checkStage}

mkdir -p ${cramFileDir}
mkdir -p ${tmpCramFileDir}

echo "## "$(date)" Start $0"
echo "ID (internalId-project-sampleName): ${internalId}-${project}-${sampleName}"

#Use old picard instead of new one "picard.jar FixMateInformation"
if java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${tmpCramFileDir} \
 -jar $EBROOTPICARD/FixMateInformation.jar \
 INPUT=${unfilteredBamDir}/${uniqueID}.bam \
 OUTPUT=${tmpCramFileDir}${uniqueID}.fixmates.bam \
 VALIDATION_STRINGENCY=LENIENT \
 CREATE_INDEX=true \
 SORT_ORDER=coordinate
then

 echo "returncode: $?";
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi


#Run scramble on 2 cores to do BAM -> CRAM conversion
echo "Starting scramble BAM to CRAM conversion";

if scramble \
 -I bam \
 -O cram \
 -r ${onekgGenomeFasta} \
 ${tmpCramFileDir}${uniqueID}.fixmates.bam \
 ${cramFileDir}${uniqueID}.cram \
 -t 2
then

 echo "returncode: $?";
 cd ${cramFileDir}
 md5sum $(basename ${cramFileDir}${uniqueID}.cram)> $(basename ${cramFileDir}${uniqueID}.cram).md5
 cd -
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "Finished scramble BAM to CRAM conversion";

#Remove temporary BAM files containing mate fixed reads
rm ${tmpCramFileDir}${uniqueID}.fixmates.bam
rm ${tmpCramFileDir}${uniqueID}.fixmates.bai


echo "## "$(date)" ##  $0 Done "


#To convert from CRAM -> BAM do:
#scramble \
#-I cram \
#-O bam \
#-m \
#-r ${onekgGenomeFasta} \
#${cramFileDir}${uniqueID}.cram \
#${cramFileDir}${uniqueID}.bam \
#-t 2



