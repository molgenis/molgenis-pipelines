#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string onekgGenomeFasta
#string VCFprefix
#string VCFsuffix
#string gatkVersion
#string selectVariantsDir
#string VCFinputDir
#string selectVariantsBiallelicSNPsVcf
#string selectVariantsBiallelicSNPsVcfPositions

echo "## "$(date)" Start $0"


getFile ${onekgGenomeFasta}
getFile ${VCFprefix}${CHR}${VCFsuffix}


${stage} GATK/${gatkVersion}
${checkStage}

mkdir -p ${selectVariantsDir}


# Extract only bi-allelic sites from VCF
if java -Xmx8g -XX:ParallelGCThreads=2 -Djava.io.tmpdir=${TMPDIR} -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
 -T SelectVariants \
 -R ${onekgGenomeFasta} \
 -V ${VCFinputDir}/${VCFprefix}${CHR}${VCFsuffix} \
 -o ${selectVariantsBiallelicSNPsVcf} \
 -selectType SNP \
 -restrictAllelesTo BIALLELIC
then
 echo "returncode: $?"; 
 putFile ${selectVariantsBiallelicSNPsVcf}
 putFile ${selectVariantsBiallelicSNPsVcf}.idx
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

# Loop through all chromosomal positions and create positions file to use during countTable merging
#Grep all positions from vcf file
zcat ${selectVariantsBiallelicSNPsVcf} | grep -v '^#' | awk '{print $1,$2}' OFS="\t" > ${selectVariantsBiallelicSNPsVcfPositions}

echo "## "$(date)" ##  $0 Done "