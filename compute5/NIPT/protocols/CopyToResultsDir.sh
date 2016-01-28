#MOLGENIS walltime=23:59:00 nodes=1 cores=1 mem=4gb

#Parameter mapping
#string resultsSampleDir
#string intermediateDir
#string reportHTML
#string qcReportHTML
#string reportPDF
#string qcReportPDF
# Change permissions
umask 0007

if [ ! -d ${resultsSampleDir} ] 
then
    mkdir -m 770 -p ${resultsSampleDir}
fi

cp ${reportPDF} ${resultsSampleDir}
cp ${reportHTML} ${resultsSampleDir}
cp ${qcReportPDF} ${resultsSampleDir}
cp ${qcReportHTML} ${resultsSampleDir}
echo "cp ${reportPDF} ${resultsSampleDir}"
echo "cp ${reportHTML} ${resultsSampleDir}"
echo "cp ${qcReportPDF} ${resultsSampleDir}"
echo "cp ${qcReportHTML} ${resultsSampleDir}"
