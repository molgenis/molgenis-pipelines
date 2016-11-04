#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=3-10:00:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string bam
#string selectVariantsBiallelicSNPsVcf
#string gatkVersion
#string ASEReadCountsDir
#string ASEReadCountsChrOutput
#string minMappingQuality
#string minBaseQuality


echo "## "$(date)" Start $0"


getFile ${onekgGenomeFasta}
getFile ${bam}
getFile ${selectVariantsBiallelicSNPsVcf}
getFile ${selectVariantsBiallelicSNPsVcf}.idx

${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${ASEReadCountsDir}

#When a site does NOT pass the minDepth filter it will NOT be emitted in output, that's why we use minDepth 0 in this case
if java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
 -T ASEReadCounter \
 -R ${onekgGenomeFasta} \
 -o ${ASEReadCountsChrOutput} \
 -I ${bam} \
 -sites ${selectVariantsBiallelicSNPsVcf} \
 -L ${selectVariantsBiallelicSNPsVcf} \
 -U ALLOW_N_CIGAR_READS \
 -minDepth 0 \
 --minMappingQuality ${minMappingQuality} \
 --minBaseQuality ${minBaseQuality}

#-drf DuplicateRead #Add this parameter to NOT remove duplicate reads

then
 echo "returncode: $?"; 

 putFile ${ASEReadCountsChrOutput}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "


