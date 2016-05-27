import argparse
import os
import os.path
import math
import sys, getopt
import json
import functools
import locale
import subprocess
import threading
import time
import tempfile
import warnings
import Queue
import pprint
import re

# valid column names
# from http://picard.sourceforge.net/picard-metric-definitions.shtml#RnaSeqMetrics
COL_NAMES = {
    'PF_BASES': 'PF Bases',
    'PF_ALIGNED_BASES': 'PF Aligned Bases',
    'RIBOSOMAL_BASES': 'Ribosomal Bases',
    'CODING_BASES': 'Coding Bases',
    'UTR_BASES': 'Utr Bases',
    'INTRONIC_BASES': 'Intronic Bases',
    'INTERGENIC_BASES': 'IntergenicB ases',
    'IGNORED_READS': 'Ignored Reads',
    'CORRECT_STRAND_READS': 'Correct Strand Reads',
    'INCORRECT_STRAND_READS': 'Incorrect Strand Reads',
    'PCT_RIBOSOMAL_BASES': 'Percent Ribosomal Bases',
    'PCT_CODING_BASES': 'Percent Coding Bases',
    'PCT_UTR_BASES': 'Percent Utr Bases',
    'PCT_INTRONIC_BASES': 'Percent Intronic Bases',
    'PCT_INTERGENIC_BASES': 'Percent Intergenic Bases',
    'PCT_MRNA_BASES': 'Percent Mrna Bases',
    'PCT_USABLE_BASES': 'Percent Usable Bases',
    'PCT_CORRECT_STRAND_READS': 'Percent Correct Strand Reads',
    'MEDIAN_CV_COVERAGE': 'Median Cv Coverage',
    'MEDIAN_5PRIME_BIAS': 'Median 5Prime Bias',
    'MEDIAN_3PRIME_BIAS': 'Median 3Prime Bias',
    'MEDIAN_5PRIME_TO_3PRIME_BIAS': 'Median 5Prime To 3Prime Bias',
}

COL_NAMES_MDUP = {
    'LIBRARY': 'Library',
    'UNPAIRED_READS_EXAMINED': 'Unpaired Reads Examined',
    'READ_PAIRS_EXAMINED': 'Read Pairs Examined',
    'UNMAPPED_READS': 'Unmapped Reads',
    'UNPAIRED_READ_DUPLICATES': 'Unmapped Reads Duplicates',
    'READ_PAIR_DUPLICATES': 'ReadPairs Duplicates',
    'READ_PAIR_OPTICAL_DUPLICATES': 'ReadPairs Optical Duplicates',
    'PERCENT_DUPLICATION': 'Percent Duplication',
    'ESTIMATED_LIBRARY_SIZE': 'Estimated LibrarySize'}

COLNAMES_ALIGNMENT = {    
    'TOTAL_READS' : 'Total Reads',
    'PF_READS' : 'PF Reads',
    'PCT_PF_READS' : 'Percent PF Reads',
    'PF_NOISE_READS' : 'PF Noise Reads',
    'PF_READS_ALIGNED' : 'PF Reads Aligned',
    'PCT_PF_READS_ALIGNED' : 'Percent PF Reads Aligned',
    'PF_ALIGNED_BASES' : 'PF Alinged Bases',
    'PF_HQ_ALIGNED_READS' : 'PF HQ Aligned Reads',
    'PF_HQ_ALIGNED_BASES' : 'PF HQ Aligned Bases',
    'PF_HQ_ALIGNED_Q20_BASES' : 'PF HQ Aligned Q20 Bases',
    'PF_HQ_MEDIAN_MISMATCHES' : 'PF HQ Median Mismatches',
    'PF_MISMATCH_RATE' : 'PF Mismatch Rate',
    'PF_HQ_ERROR_RATE' : 'PF HQ Error Rate',
    'PF_INDEL_RATE' : 'PF Indel Rate',
    'MEAN_READ_LENGTH' : 'Mean Read Length',
    'READS_ALIGNED_IN_PAIRS' : 'Reads Aligned In Pairs',
    'PCT_READS_ALIGNED_IN_PAIRS' : 'Percent Reads Aligned In Pairs',
    'BAD_CYCLES' : 'Bad Cycles',
    'STRAND_BALANCE' : 'Strand Balance'}

def natural_sort(l):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ]
    return sorted(l, key = alphanum_key)



def meanStd(d):
    """
    Calculate the mean and standard deviation of histogram d.

    @arg d: Histogram of real values.
    @type d: dict[int](float)

    @returns: The mean and standard deviation of d.
    @rtype: tuple(float, float)
    """
    sum_l = 0
    sumSquared_l = 0
    n = 0

    for i in d:
        sum_l += i * d[i]
        sumSquared_l += (d[i] * (i * i))
        n += d[i]
    #for
    
    mean = sum_l / float(n)
    return {'Mean.insertsize' : mean, 'stDev' :+math.sqrt((sumSquared_l / float(n)) - (mean * mean))}
    
def parse_metrics_file(metrics_path):
    """Given a path to a Picard CollectRnaSeqMetrics output file, return a
    dictionary consisting of its column, value mappings.
    """
    data_mark = 'PF_BASES'
    tokens = []
    with open(metrics_path, 'r') as source:
        line = source.readline().strip()
        fsize = os.fstat(source.fileno()).st_size
        while True:
            if not line.startswith(data_mark):
                # encountering EOF before metrics is an error
                if source.tell() == fsize:
                    raise ValueError("Metrics not found inside %r" % \
                            metrics_path)
                line = source.readline().strip()
            else:
                break

        assert line.startswith(data_mark)
        # split header line and append to tokens
        tokens.append(line.split('\t'))
        # and the values (one row after)
        tokens.append(source.readline().strip().split('\t'))
    data = {}
    for col, value in zip(tokens[0], tokens[1]):
        if not value:
            data[COL_NAMES[col]] = None
        elif col.startswith('PCT') or col.startswith('MEDIAN'):
            if value != '?':
                data[COL_NAMES[col]] = float(value)
            else:
                warnings.warn("Undefined value for %s in %s: %s" % (col,
                    metrics_path, value))
                data[COL_NAMES[col]] = None
        else:
            assert col in COL_NAMES, 'Unknown column: %s' % col
            data[COL_NAMES[col]] = int(value)

    return data
    
def parse_mdup_metrics_file(metrics_path):
    """Given a path to a Picard DuplicationMetrics output file, return a
    dictionary consisting of its column, value mappings.
    """
    data_mark = 'LIBRARY'
    tokens = []
    with open(metrics_path, 'r') as source:
        line = source.readline().strip()
        fsize = os.fstat(source.fileno()).st_size
        while True:
            if not line.startswith(data_mark):
                # encountering EOF before metrics is an error
                if source.tell() == fsize:
                    raise ValueError("Metrics not found inside %r" % \
                            metrics_path)
                line = source.readline().strip()
            else:
                break

        assert line.startswith(data_mark)
        # split header line and append to tokens
        tokens.append(line.split('\t'))
        # and the values (one row after)
        tokens.append(source.readline().strip().split('\t'))
    data = {}
    for col, value in zip(tokens[0], tokens[1]):
        if not value:
            data[COL_NAMES_MDUP[col]] = None
        elif col.startswith('PCT') or col.startswith('PERCENT'):
            if value != '?':
                data[COL_NAMES_MDUP[col]] = float(value)
            else:
                warnings.warn("Undefined value for %s in %s: %s" % (col,
                    metrics_path, value))
                data[COL_NAMES_MDUP[col]] = None
        elif col.startswith('LIBRARY'):
            if value != '?':
                data[COL_NAMES_MDUP[col]] = value
            else:
                warnings.warn("Undefined value for %s in %s: %s" % (col,
                    metrics_path, value))
                data[COL_NAMES[col]] = None 
        else:
            assert col in COL_NAMES_MDUP, 'Unknown column: %s' % col
            data[COL_NAMES_MDUP[col]] = int(value)

    return data

def getFlagstat(fsFile):
  """
  Get the number of mapped reads from flagstat.
  """

  with open (fsFile, 'r') as f:
    for line in f:
      line = line.rstrip('\n')
      if "total" in line:
        total = int(line.split(' ')[0])
      if "mapped (" in line:
        mapped = int(line.split(' ')[0])
      if "duplicates" in line:
        dup = int(line.split(' ')[0])
    return {'mappedReads' : mapped,'totalReads' : total ,'duplicates' : dup}

def parse_Star_Log_File(starLog):
  """
  Parse starLog file into hash.
  """

  with open (starLog, 'r') as f:
    for line in f:
      line = line.rstrip('\n')
      if str(line) != '':
      	total = line.split('|')
      	
      	
      	if len(total) > 1:
      	  #print total[0].strip() +total[1]
      	  print("{0:<40s}{1:<11}".format(total[0].strip(), total[1]))
      	else:
      	   print("{0:<40s}\t".format(total[0].strip()))
    #return {'mapped.reads' : mapped,'total.reads' : total ,'duplicates' : dup}

def parse_alignment_metrics_file(metrics_path):
    """Given a path to a Picard CollectMultipleMetrics [alignmentMetrics] output file, return a
    dictionary consisting of its column, value mappings.
    """
    data_mark = 'CATEGORY'
    tokens = []
    with open(metrics_path, 'r') as source:
        line = source.readline().strip()
        fsize = os.fstat(source.fileno()).st_size
        while True:
            if not line.startswith(data_mark):
                # encountering EOF before metrics is an error
                if source.tell() == fsize:
                    raise ValueError("Metrics not found inside %r" % \
                            metrics_path)
                line = source.readline().strip()
            else:
                break

        assert line.startswith(data_mark)
        # split header line and append to tokens
        tokens.append(line.split('\t'))
	line = source.readline().strip()
	if line.startswith('UNPAIRED'):
          # and the values (one row after)
       	  tokens.append(line.split('\t'))
	else:
	 # and the values (three rows after)
	  source.readline().strip()
	  tokens.append(source.readline().strip().split('\t'))
	
	
    data = {}
    for col, value in zip(tokens[0], tokens[1]):
        if col not in COLNAMES_ALIGNMENT:
            continue;
        else:
	  if not value:
            data[COLNAMES_ALIGNMENT[col]] = None
          elif value != '?':
            data[COLNAMES_ALIGNMENT[col]] = value
          else:
            warnings.warn("Undefined value for %s in %s: %s" % (col,
            metrics_path, value))
            data[COLNAMES_ALIGNMENT[col]] = None

    return data

def getHist(file, begin, end):
  """
  Get the GC content per sequence from the fastqc data file given a sampleid.
  """

  collect = False
  data = {}

  with open (file, 'r') as f:
    for line in f:
      line = line.rstrip('\n')
      if collect and end in line:
        collect = False
      if collect and len(line)>0:
        data[int(line.split('\t')[0])]=float(line.split('\t')[1])
      if begin in line:
        collect = True
  return data


def main(argv):
  """
  Main entry point.
  """

  alignmentMetrics = ''
  insertSizeMetrics = ''
  RnaSeqMetrics = ''
  flagstats = ''
  dupMetrics = ''
   
  try:
    opts, args = getopt.getopt(argv,"h:a:i:r:f:d:",["alignmentMetrics=","insertSizeMetrics=","RnaSeqMetrics=","flagstats=","dupMetrics="])
         
  except getopt.GetoptError:
    print 'pull_RNA_Seq_Stats.py\n -a <alignmentMetrics>\n -r <RnaSeqMetrics>\n -i <insertSizeMetrics>\n -f <flagstats>\n -d  <dupMetrics>\n'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
       print 'pull_RNA_Seq_Stats.py -a <alignmentMetrics>\n -r <RnaSeqMetrics>\n -i <insertSizeMetrics>\n -f <flagstats>\n -d  <dupMetrics>\n\n'
       sys.exit(2)
    elif opt in ("-r", "--RnaSeqMetrics"):
	   RnaSeqMetrics = arg
    elif opt in ("-i", "--insertSizeMetrics"):
       insertSizeMetrics = arg
    elif opt in ("-d", "--dupMetrics"):
       dupMetrics = arg
    elif opt in ("-a", "--alignmentMetrics"):
       alignmentMetrics = arg   
    elif opt in ("-f", "--flagstats"):
       flagstats = arg   
         
  insertSizeFile = insertSizeMetrics
  RnaSeqMetrics = RnaSeqMetrics
  fsFileFull = flagstats
  dupMetrics = dupMetrics
  alignmentMetrics = alignmentMetrics
  data = {}
    
  if os.path.isfile(insertSizeFile) and os.access(insertSizeFile, os.R_OK):
    data['insertSizeHist'] = getHist(insertSizeFile, 'insert_size', 'EOF')
  data['map2Full'] = getFlagstat(fsFileFull)
  data['RnaSeqMetrics'] = parse_metrics_file(RnaSeqMetrics)
  data['dupMetrics'] = parse_mdup_metrics_file(dupMetrics)
  data['alignmentMetrics'] = parse_alignment_metrics_file(alignmentMetrics)
	
  #data['starLog'] = parse_Star_Log_File(starLog)
	
  #print alignmentMetrics stats in tablular format
  print "\n## PICARD:ALIGNMENTMETRICS ##\t\n"
  alignmentMetrics = data['alignmentMetrics']
  for key in natural_sort(alignmentMetrics.keys()):
    print("{0:<40s}\t{1:<30}".format(key,alignmentMetrics[key]))	

  #print flagstat stats in tablular format 
  print "\n## SAMTOOLS:FLAGSTAT ##\t\n"
  map2Full = data['map2Full']
  for key in natural_sort(map2Full.keys()):
    print("{0:<40s}\t{1:<11}".format(key, map2Full[key]))
  
  #print CollectRnaSeqMetrics stats in tablular format
  print "\n## PICARD:COLLECTRNASEQMETRICS ##\t\n"
  RnaSeqMetrics = data['RnaSeqMetrics']
  for key in natural_sort(RnaSeqMetrics.keys()):
    print("{0:<40s}\t{1:<30}".format(key, RnaSeqMetrics[key]))
  
  #print dupMatrics stats in tablular format
  print "\n ## PICARD:MARKDEDUPMETRICS ##\t\n"
  dupMetrics = data['dupMetrics']
  for key in natural_sort(dupMetrics.keys()):
    print("{0:<40s}\t{1:<30}".format(key, dupMetrics[key]))
       
  if os.path.isfile(insertSizeFile) and os.access(insertSizeFile, os.R_OK):
    print "\n## PICARD:INSERTSIZEMERTICS ##\t\n"
    insertSizeHist = meanStd(data['insertSizeHist'])  
    for key in natural_sort(insertSizeHist.keys()):
      print("{0:<40s}\t{1:<11.3f}".format(key, insertSizeHist[key]))
  
  
if __name__ == "__main__":
  main(sys.argv[1:])

