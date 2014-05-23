#MOLGENIS walltime=66:00:00 nodes=1 cores=10 mem=8

###### Renaming because we call another protocol:

#input:
<#assign matefixedbam=sortedrecalbam />

#output:
<#assign matefixedcovariatecsv=sortedrecalcovariatecsv />

<#include "Covariates.ftl" />
