#download executable
lcg-cp lfn://grid/lsgrid/${srm_name} \
file:///$TMPDIR/${just_name}
chmod 755 $TMPDIR/${just_name}

/bin/hostname

