#upload result data; 
#created an empty file first to avoid uploading error if file is not created 
echo -n "" >> file:///$TMPDIR/${just_name}
lcg-cr -l lfn://grid/lsgrid/${srm_name} \
file:///$TMPDIR/${just_name}

