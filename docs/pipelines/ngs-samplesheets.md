# Creating samplesheet
Creating a samplesheet is necessary to start the pipeline and that the pipeline knows which samples to run. The samplesheet should be a comma seperated file.
An example of a samplesheet template is below, all the headers are required but rows are not necessarily to be filled

project,run,sequencingStartDate,sequencer,flowcell,externalSampleID,seqType,capturingKit,internalSampleID,barcode,lane,barcodeType,contact,Gender
testproject,run1,010101,sequencer2,flowcell3,S1,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S1,ATCGAA,1,,,Male
testproject,run1,010101,sequencer2,flowcell3,S2,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S2,TTAACC,1,,,Female
testproject,run1,010101,sequencer2,flowcell3,S3,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S3,GACAAA,1,,,Male
testproject,run1,010101,sequencer2,flowcell3,S4,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S4,ACGTTA,1,,,Unknown

columns that **cannot be blank** are the following:

- project (project name)
- run (runnumber)
- sequencingStartDate (yymmdd)
- sequencer (name of sequencer)
- flowcell (flowcell name)
- externalSampleID (name of the sample)
- seqType (SR (single read) or PE(paired end))
- capturingKit (see below for more info)


The columns sequencingStartDate, sequencer, run and flowcell are combined describing the rawdata folder. e.g. 161214\_NB501093\_0100_ABCDEF3XX 
This naming format is the same as the naming of the raw data from the sequencer. 

The **capturingKit** column should contain the path relative to /apps/data/ followed by a backslash (to escape the forward slash) followed by a forward slash and then the name of the capturingkit
e.g. Agilent\/ONCO_v3
e.g. UMCG\/All\_Exon_v1

can be blank:

- internalSampleID 
- barcode (when there is a barcode used fill in barcode, **NOTE: should be filled in case of external samples, see below** )
- lane (in case of different lanes fill in lane number)
- barcodeType (can fill the barcode type e.g. AGI,rPI etc)
- contact (who is the person to contact)
- Gender (Male,Female or Unknown)

## External samples

when there are samples from an external source (not in-house), columns externalFastQ\_1 and externalFastQ\_2 should be added and filled with the name of the fastq.gz (or fq.gz), these files should be placed in the rawdata folder(that folder should have the naming convention as mentioned above, sequencingStartdate\_sequencer\_run\_flowcell) The name is not strict and can be anything e.g. 010101_sequencer2_run1_flowcell3
**Note: The name of the folder should be the same as in the samplesheet**
**Note2:Barcode should now be filled with unique names per sample (e.g. use same name as externalSampleID)**

project,run,sequencingStartDate,sequencer,flowcell,externalSampleID,seqType,capturingKit,internalSampleID,barcode,lane,barcodeType,contact,Gender,externalFastQ_1,externalFastQ_2
testproject,run1,010101,sequencer2,flowcell3,Sample1,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S1,Sample1,,,Male,1_S1_L001_R1_001.fastq.gz,1_S1_L001_R2_001.fastq.gz
testproject,run1,010101,sequencer2,flowcell3,Sample2,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S2,Sample2,,,Female,2_S2_L001_R1_001.fastq.gz,2_S2_L001_R2_001.fastq.gz
testproject,run1,010101,sequencer2,flowcell3,Sample3,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S3,Sample3,,,Male,3_S3_L001_R1_001.fastq.gz,3_S3_L001_R2_001.fastq.gz
testproject,run1,010101,sequencer2,flowcell3,Sample4,PE,PATH_RELATIVE_TO_apps/data/${NAMEOFCAPTURINGKIT},S4,Sample4,,,Unknown,4_S4_L001_R1_001.fastq.gz,4_S4_L001_R2_001.fastq.gz
