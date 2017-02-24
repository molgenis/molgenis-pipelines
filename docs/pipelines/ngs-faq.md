# Demultiplexing
## Pipeline stopped in first step (Bcl2FastQ). 

**Cause:** The samplesheet is corrupt

**Solution:** 
- check if there are no windows signs in the samplesheet (^M) → mac2unix
- No empty lines at the bottom (NB: empty means only comma’s)
- Are there required fields written with ‘none’ instead of ‘None’

## All the reads are discarded

**Possible cause:** There is an unknown barcodeType, the step will crash.

**Solution:** 
Fill in a barcodeType in the samplesheet that is valid (and create an issue in molgenis-pipelines on github that a new barcode should be added to the known barcodeTypes


## Pipeline is not producing correct data

**Possible cause:**	Are there dual barcodes?

**Solution:**	
In case of dual barcodes, the second barcode should be reversed complement

# NGS_DNA
