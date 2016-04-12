import argparse
import csv     # imports the csv module
import sys
from collections import defaultdict

parser = argparse.ArgumentParser(description='Process some integers.')
parser.add_argument("--input")
parser.add_argument("--logfile")
args = parser.parse_args()

columns = defaultdict(list)
f = open(args.input, 'r') # opens the csv file
print("inputfile:" + args.input)	
reader = csv.DictReader(f)  # creates the reader object

w = open(args.logfile, 'w')
print("logfile:" + args.logfile)


hasRows = False
for number, row in enumerate(reader,1):   # iterates the rows of the file in orders
	hasRows = True
	for sleutel in ('externalSampleID','project','sequencer','sequencingStartDate','flowcell','run','flowcell','lane','seqType','prepKit','capturingKit','barcode','barcodeType'):
		if sleutel not in row.keys():
			w.write("One of the headers is missing: (externalSampleID,project,sequencer,sequencingStartDate,flowcell,run,flowcell,lane,seqType,prepKit,capturingKit,barcode,barcodeType)")
			sys.exit(1)
		if row[sleutel] == "":
			if sleutel in ('capturingKit','barcode','barcodeType'):
				w.write("The variable " + sleutel + " on line " + str(number) +  " is empty! Please fill in None (this to be sure that is not missing)")
			else:
				print("fout")
				w.write("The variable " + sleutel + " on line " + str(number) +  " is empty!")
			w.close()
			sys.exit(1)

if not hasRows:
	sys.exit(1)
w.close()
f.close()      # closing


