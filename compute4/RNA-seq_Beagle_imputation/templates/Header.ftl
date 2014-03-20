#!/bin/bash
#PBS -N ${jobname}
#PBS -q ${clusterQueue}
#PBS -l nodes=1:ppn=${cores}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${jobname}.err
#PBS -o ${jobname}.out
#PBS -W umask=0007
#PBS -l file=10gb

hostname
# Configures the GCC bash environment
. ${bashrc}

<#function ssvQuoted items>
	<#local result = "">
	<#list items as item>
		<#if item_index != 0>
			<#local result =  result + " ">
		</#if>
		<#local result = result + "\"" + item + "\"">
	</#list>
	<#return result>
</#function>


inputs()
{
  for name in $@
  do
    if test ! -e $name;
    then
      echo "$name is missing" 1>&2
      exit 1;
    fi
  done
}

alloutputsexist()
{
  all_exist=true
  for name in $@
  do
    if test ! -e $name;
    then
        all_exist=false
    fi
  done
  if $all_exist;
  then
      echo "skipped"
      echo "skipped" 1>&2
      sleep 30
      exit 0;
  else
      return;
  fi
}

