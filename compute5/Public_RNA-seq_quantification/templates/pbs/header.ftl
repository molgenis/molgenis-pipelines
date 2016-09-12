#PBS -N ${taskId}
#PBS -q ${queue}
#PBS -l nodes=${nodes}:ppn=${ppn}
#PBS -l walltime=${walltime}
#PBS -l mem=${mem}
#PBS -e ${taskId}.err
#PBS -o ${taskId}.out
#PBS -W umask=0007

# For bookkeeping how long your task takes
MOLGENIS_START=$(date +%s)

#
## Header for PBS backend
#

declare MC_tmpFolder="tmpFolder"
declare MC_tmpFile="tmpFile"

function makeTmpDir {
 	base=$(basename $1)
        dir=$(dirname $1)	
	echo "dir $dir"
        echo "base $base"
	if [[ -d $1 ]]
	then
		dir=$dir/$base
	fi
        myMD5=$(md5sum $0)
        IFS=' ' read -a myMD5array <<< "$myMD5"
        MC_tmpFolder=$dir/tmp_${taskId}_$myMD5array/
        mkdir -p $MC_tmpFolder
        if [[ -d $1 ]]
        then
                MC_tmpFile="$MC_tmpFolder"
        else
                MC_tmpFile="$MC_tmpFolder/$base"
        fi
}
echo Running on node: `hostname`

#highly recommended to use
set -e # exit if any subcommand or pipeline returns a non-zero status
set -u # exit if any uninitialised variable is used

# Set location of *.env files
#ENVIRONMENT_DIR="$PBS_O_WORKDIR"

# If you detect an error, then exit your script by calling this function
exitWithError(){
	errorCode=$1
	errorMessage=$2
	echo "$errorCode: $errorMessage --- TASK '${taskId}.sh' --- ON $(date +"%Y-%m-%d %T"), AFTER $(( ($(date +%s) - $MOLGENIS_START) / 60 )) MINUTES" >> $ENVIRONMENT_DIR/molgenis.error.log
	exit $errorCode
}

# For bookkeeping how long your task takes
MOLGENIS_START=$(date +%s)

# Show that the task has started
touch $ENVIRONMENT_DIR/${taskId}.sh.started

<#noparse>
# Define the root to all your tools and data
WORKDIR=${WORKDIR}

# Source getFile, putFile, inputs, alloutputsexist
include () {
	if [[ -f "$1" ]]; then
		source "$1"
		echo "sourced $1"
	else
		echo "File not found: $1"
	fi		
}
include $GCC_HOME/gcc.bashrc
getFile()
{
        ARGS=($@)
        NUMBER="${#ARGS[@]}";
        if [ "$NUMBER" -eq "1" ]
        then
                myFile=${ARGS[0]}

                if test ! -e $myFile;
                then
                                echo "WARNING in getFile/putFile: $myFile is missing" 1>&2
                fi

        else
                echo "Example usage: getData \"\$TMPDIR/datadir/myfile.txt\""
        fi
}

putFile()
{
        `getFile $@`
}

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

outputs()
{
  for name in $@
  do
    if test -e $name;
    then
      echo "skipped"
      echo "skipped" 1>&2
      exit 0;
    else
      return 0;
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
      return 0;
  fi
}
</#noparse>

#
## End of header for PBS backend
#

