#MOLGENIS walltime=66:00:00

###### Renaming because we call another protocol:

#input:
<#assign matefixedbam=sortedrecalbam />

#output:
<#assign matefixedcovariatecsv=sortedrecalcovariatecsv />

<#include "Covariates.ftl" />
