#MOLGENIS nodes=1 ppn=2 mem=10gb walltime=05:59:00

### variables to help adding to database (have to use weave)
#string project
###
#string stage
#string checkStage
#string CHR
#string sampleCountsTable
#string selectVariantsBiallelicSNPsVcfPositions


#Function to check if a value is present in array/list
containsElement () {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}





echo "## "$(date)" Start $0"


getFile ${selectVariantsBiallelicSNPsVcfPositions}


${checkStage}

mkdir -p ${countsTableDir}


#Check if output sample file already exists, if so exit
if [ -f "${sampleCountsTable}" ];
then
   echo -e -n "${sampleCountsTable} exists, deleting it\n"
   rm ${sampleCountsTable}
   #exit 2;
else
   echo -e -n "${sampleCountsTable} does not exist, continuing analysis\n"
fi


while read line
do
	POS=$line
	#Create command to grep
	GREPCMD="$CHR\t$POS\t"
	#Echo chr and pos for debugging purpose
	#echo -e -n "$GREPCMD"
	echo -e -n "Checking position: $GREPCMD \n"
	
	#Grep counts from file
	RESULTCOUNTS=`grep -P "$GREPCMD" ${ASEReadCountsSampleChrOutput} | awk '{print $6","$7}'`
	#If variable is longer than 0 characters it contains counts, print them, otherwise print 0,0
	[ -z "$RESULTCOUNTS" ] && echo "0,0" >> ${sampleCountsTable} || echo "$RESULTCOUNTS" >> ${sampleCountsTable}

done<${selectVariantsBiallelicSNPsVcfPositions}

#Putfile the results
if [ -f "${sampleCountsTable}" ];
then
 echo "returncode: $?"; 
 putFile ${sampleCountsTable}
 echo "succes moving files";
else
 echo "returncode: $?";
 echo "fail";
fi

echo "## "$(date)" ##  $0 Done "