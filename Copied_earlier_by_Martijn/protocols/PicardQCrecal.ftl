#MOLGENIS walltime=20:00:00 mem=5

#FOREACH externalSampleID
<#assign runtimelog = runtimelog[0] />
<#assign fileprefix = "externalSampleID " + externalSampleID>

###### Renaming because we call another protocol:
#inputs:
<#assign sortedbam=mergedbam />

#outputs:
<#assign alignmentmetrics=samplealignmentmetrics />
<#assign gcbiasmetrics=samplegcbiasmetrics />
<#assign gcbiasmetricspdf=samplegcbiasmetricspdf />
<#assign insertsizemetrics=sampleinsertsizemetrics />
<#assign insertsizemetricspdf=sampleinsertsizemetricspdf />
<#assign meanqualitybycycle=samplemeanqualitybycycle />
<#assign meanqualitybycyclepdf=samplemeanqualitybycyclepdf />
<#assign qualityscoredistribution=samplequalityscoredistribution />
<#assign qualityscoredistributionpdf=samplequalityscoredistributionpdf />
<#assign hsmetrics=samplehsmetrics />
<#assign bamindexstats=samplebamindexstats />

<#include "PicardQC.ftl">