#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string shapeitVersion
#string mendelianErrorCheckOutputPrefix
#string phasedFamilyOutputDir
#string phasedFamilyOutputPrefix
#string haplotypeReferencePanelShapeit2Prefix
#string geneticMapChrPrefix
#string geneticMapChrPostfix



echo "## "$(date)" Start $0"


${stage} shapeit/${shapeitVersion}
${checkStage}

mkdir -p ${phasedFamilyOutputDir}
        
#Run Shapeit2 for trio phasing
shapeit \
-B ${mendelianErrorCheckOutputPrefix} \
-M ${geneticMapChrPrefix}${CHR}${geneticMapChrPostfix} \
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