DIR="$( cd "$( dirname "<#noparse>${BASH_SOURCE[0]}</#noparse>" )" && pwd )"
touch $DIR/${workflowfilename}.started

<#if scheduler == "PBS">

<#foreach j in jobs>
#${j.name}
${j.name}=$(qsub -N ${j.name}<#if j.prevSteps_Name?size &gt; 0> -W depend=afterok<#foreach d in j.prevSteps_Name>:$${d}</#foreach></#if> ${j.name}.sh)
echo $${j.name}
sleep 0
</#foreach>

<#elseif scheduler == "BSUB">

<#foreach j in jobs>
#${j.name}
bsub < "${j.name}.sh"<#if j.prevSteps_Name?size &gt; 0> -w 'done("<#foreach d in j.prevSteps_Name>${d}")<#if d_has_next> && done("</#if></#foreach>'</#if>
echo $${j.name}
sleep 0
</#foreach>

</#if>
