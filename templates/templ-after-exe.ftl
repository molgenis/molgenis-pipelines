returnCode=$?

if [ $returnCode -eq 0 ]
then
echo "FINISHED_SUCCESS" 2>&1 | tee -a ${log}
fi
