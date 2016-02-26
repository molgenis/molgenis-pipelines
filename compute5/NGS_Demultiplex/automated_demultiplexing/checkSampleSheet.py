import argparse
import csv     # imports the csv module
import sys
from collections import defaultdict

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument("--input")
args = parser.parse_args()

columns = defaultdict(list)
f = open(args.input, 'r') # opens the csv file
print(args.input)	
reader = csv.DictReader(f)  # creates the reader object

hasRows = False
for number, row in enumerate(reader,1):   # iterates the rows of the file in orders
	hasRows = True
	for sleutel in ('externalSampleID','project','sequencer','sequencingStartDate','flowcell','run','flowcell','lane','seqType','prepKit','capturingKit','barcode','barcodeType'):
		if sleutel not in row.keys():
			print("One of the headers is missing: (externalSampleID,project,sequencer,sequencingStartDate,flowcell,run,flowcell,lane,seqType,prepKit,capturingKit,barcode,barcodeType)")
			sys.exit(1)
		if row[sleutel] == "":
			if sleutel in ('capturingKit','barcode','barcodeType'):
				print("The variable " + key + " on line " + str(line) +  " is empty!")
			else:
				print("The variable " + key + " on line " + str(line) +  " is empty! Please fill in None (this to be sure that is not missing)")
			sys.exit(1)

if not hasRows:
	sys.exit(1)
f.close()      # closing


