
<#foreach j in jobs>
#${j.name}
${j.name}=$(qsub -N ${j.name}<#if j.prevSteps_Name?size &gt; 0> -W depend=afterok<#foreach d in j.prevSteps_Name>:$${d}</#foreach></#if> ${j.name}.sh)
echo $${j.name}
</#foreach>

