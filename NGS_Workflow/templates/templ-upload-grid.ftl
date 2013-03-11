#upload result data:
echo -n "SUM_ADLER32_${output} \t" 2>&1 | tee -a ${log}
adler32 ${output} 2>&1 | tee -a ${log}

lcg-cr -l lfn://grid/${lfn_name} \
file:///${output}

