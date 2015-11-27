#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping
#string resultsDir
#string intermediateDir
#string reportHTML
#string qcReportHTML
#string reportPDF
#string qcReportPDF
# Change permissions
umask 0007


cp ${reportPDF} ${resultsDir}
cp ${reportHTML} ${resultsDir}
cp ${qcReportPDF} ${resultsDir}
cp ${qcReportHTML} ${resultsDir}
echo "cp ${reportPDF} ${resultsDir}"
echo "cp ${reportHTML} ${resultsDir}"
echo "cp ${qcReportPDF} ${resultsDir}"
echo "cp ${qcReportHTML} ${resultsDir}"
