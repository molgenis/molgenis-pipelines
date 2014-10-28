#MOLGENIS walltime=23:59:00 mem=10mb ppn=2

#list sjdbFileChrStartEnd
#string projectSjdbFileChrStartEnd

alloutputsexist \
 ${projectSjdbFileChrStartEnd}

echo "## "$(date)" ##  $0 Started "

for sjdbFile in "${sjdbFileChrStartEnd[@]}"
do
	echo "## "$(date)" ##  getFile= "$sjdbFile
	getFile $sjdbFile	
done

files=$(printf '%s ' "${sjdbFileChrStartEnd[@]}")
echo "files to merge: $files"

#keep every annotated splice juction. then from the novel spice juctions it removes $1: mitochondrial isoforms (and $5: non-canonical intron motifs. intron motif(the sequence present in the intron bordeing the splice junction): 0: non-canonical; 1: GT/AG, 2: CT/AC, 3: GC/AG, 4: CT/GC, 5: AT/AC, 6: GT/AT)



cat $files | awk '{if($6 == 1 || ($5 > 0 && $1 != "M" && $1 != "MT")){print $0}}' > ${projectSjdbFileChrStartEnd}
#more lenient: cat ${sjdbFileChrStartEnd[@]} | awk '{if($6 == 1 ||$1 != "M" && $1 != "MT" ){print $0}}' > ${projectSjdbFileChrStartEnd}

putFile ${projectSjdbFileChrStartEnd}

if [ ! -z "$PBS_JOBID" ]; then
	echo "## "$(date)" Collecting PBS job statistics"
	qstat -f $PBS_JOBID
fi

echo "## "$(date)" ##  $0 Done "
