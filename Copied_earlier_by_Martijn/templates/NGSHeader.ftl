<#if externalSampleID?exists>
<#if externalSampleID?is_sequence># This script is processing samples:
<#list externalSampleID as sampleToProcess># ${sampleToProcess}
</#list>
<#else># This script is processing sample: ${externalSampleID}</#if>
</#if>
