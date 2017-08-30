#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string shapeitVersion
#string convertVCFtoPlinkPrefix
#string phasedFamilyOutputDir
#string phasedFamilyOutputPrefix
#string haplotypeReferencePanelShapeit2Prefix



echo "## "$(date)" Start $0"


${stage} shapeit/${shapeitVersion}
${checkStage}

mkdir -p ${phasedFamilyOutputDir}
        
#Run Shapeit2 for trio phasing
shapeit \
-B ${convertVCFtoPlinkPrefix} \
-M /apps/data/www.shapeit.fr/genetic_map_b37/genetic_map_chr20_combined_b37.txt \
--input-ref ${haplotypeReferencePanelShapeit2Prefix}.hap.gz \
${haplotypeReferencePanelShapeit2Prefix}.legend.gz \
${haplotypeReferencePanelShapeit2Prefix}.samples \
--duohmm \
-W 5 \
-O ${phasedFamilyOutputPrefix}


cd ${phasedFamilyOutputDir}/
md5sum $(basename ${phasedFamilyOutputPrefix}.sample) > ${phasedFamilyOutputPrefix}.sample.md5
md5sum $(basename ${phasedFamilyOutputPrefix}.haps) > ${phasedFamilyOutputPrefix}.haps.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "