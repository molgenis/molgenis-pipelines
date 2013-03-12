#download executable
lcg-cp lfn://grid/${lfn_name} \
file:///${input}

echo -n "SUM_ADLER32_${input} \t" 2>&1 | tee -a ${log}
adler32 ${input} 2>&1 | tee -a ${log}

chmod 755 ${input}

/bin/hostname

