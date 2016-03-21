HEADER=$(head -1 $1)
OLDIFS=$IFS
IFS=','
array=($HEADER)
IFS=$OLDIFS
count=0
DIR=$2
for i in "${array[@]}"
do
  	if [ "${i}" == "externalSampleID" ]
        then
            	awk '{FS=","}{print $'$count'}' $1 > $DIR/countRows.txt
        fi
	count=$((count + 1))
done

cat $DIR/countRows.txt | sort -V | uniq | wc -l
rm $DIR/countRows.txt
