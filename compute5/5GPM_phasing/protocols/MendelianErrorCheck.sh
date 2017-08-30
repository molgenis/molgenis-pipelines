#MOLGENIS nodes=1 ppn=2 mem=8gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string shapeitVersion
#string convertVCFtoPlinkPrefix
#string mendelianErrorCheckDir
#string phasedFamilyOutputPrefix
#string haplotypeReferencePanelShapeit2Prefix
#string geneticMapChrPrefix
#string geneticMapChrPostfix
#string mendelianErrorCheckOutputPrefix


echo "## "$(date)" Start $0"


${stage} shapeit/${shapeitVersion}
${checkStage}

mkdir -p ${mendelianErrorCheckDir}

#Run shapeit check to detect mendelian errors, which are written away in output log file
shapeit \
-check \
-B ${convertVCFtoPlinkPrefix} \
-M ${geneticMapChrPrefix}${CHR}${geneticMapChrPostfix} \
--input-ref ${haplotypeReferencePanelShapeit2Prefix}.hap.gz \
${haplotypeReferencePanelShapeit2Prefix}.legend.gz \
${haplotypeReferencePanelShapeit2Prefix}.samples \
--output-log ${mendelianErrorCheckOutputPrefix}


cd ${mendelianErrorCheckDir}/
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.ind.me) > ${mendelianErrorCheckOutputPrefix}.ind.me.md5
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.ind.mm) > ${mendelianErrorCheckOutputPrefix}.ind.mm.md5
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.snp.me) > ${mendelianErrorCheckOutputPrefix}.snp.me.md5
md5sum $(basename ${mendelianErrorCheckOutputPrefix}.snp.mm) > ${mendelianErrorCheckOutputPrefix}.snp.mm.md5
cd -
echo "returncode: $?";


echo "## "$(date)" ##  $0 Done "