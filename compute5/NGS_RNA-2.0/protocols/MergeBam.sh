
#list externalSampleID

module load picard-tools/${picardVersion}

inputs <#list sortedrecalbam as srb> "${srb}" </#list>
alloutputsexist "${mergedbam}" \
"${mergedbamindex}"

<#if sortedrecalbam?size == 1>
        #cp ${sortedrecalbam[0]} ${mergedbam}
        #cp ${sortedrecalbam[0]}.bai ${mergedbamindex}
        ln -s ${sortedrecalbam[0]} ${mergedbam}
        ln -s ${sortedrecalbam[0]}.bai ${mergedbamindex}
<#else>
        java -jar -Xmx6g ${mergesamfilesjar} \
        <#list sortedrecalbam as srb>INPUT=${srb} \
        </#list>
        ASSUME_SORTED=true USE_THREADING=true \
        TMP_DIR=${tempdir} MAX_RECORDS_IN_RAM=6000000 \
        OUTPUT=${mergedbam} \
        SORT_ORDER=coordinate \
        VALIDATION_STRINGENCY=SILENT
        
        java -jar -Xmx3g ${buildbamindexjar} \
        INPUT=${mergedbam} \
        OUTPUT=${mergedbamindex} \
        VALIDATION_STRINGENCY=LENIENT \
        MAX_RECORDS_IN_RAM=1000000 \
        TMP_DIR=${tempdir}
</#if>
