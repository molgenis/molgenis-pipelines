# Alternative parameter file formats

More parameters can be specified using the next format

example.csv
```
  parameter1, parameter2
  value11,    value21
  value12,    value22
  value13,    value23
```
Alternatively, parameters can be specified in the +.properties+ style. The parameters file also should have
the +.properties+ extension.

example.properties

```
  parameter1 = value11, value12, value13
  parameter2 = value21, value22, value23
```

Values for the workflow to iterate over can be passed as CSV file with parameter names in the header (a-zA-Z0-9 and underscore, starting with a-zA-Z) and parameter values in each row. Use quotes to escape commas, e.g. "a,b".

Each value is one of the following:

* a string
* a Freemarker template [documentation](http://freemarker.org/)
* a series i..j (where i and j are two integers), meaning from i to j including i and j
* a list of ';' separated values (may contain templates)

# Joining parameter files

You can combine multiple parameter files: the values will be 'natural joined' based on overlapping columns.

Example with two or more parameter files:

````bash
  molgenis --path path/to/workflow -p f1.csv -p f2.csv -w workflow.csv
```

f1.csv (white space will be trimmed):

```
  p0,  p2
  x,   1
  y,   2
```
  
f2.csv (white space will be trimmed):
```
  p1,  p2,    p3,     p4
  v1,  1..2,  a;b,    file${p2}
```

Merged and expanded result for f1.csv + f2.csv:

```
  p0,  p1,  p2,   p3,   p4
  x,   v1,  1,    a,    file1 
  x,   v1,  1,    b,    file1
  y,   v1,  2,    a,    file2
  y,   v1,  2,    b,    file2
```

More complex parameter examples can combine values with template, as following:

```bash
  foo=    item1 , item2
  bar=    ${foo}, item3
  number= 123
```

Here, variable 'bar' has two values of variable 'foo'.

# Specifying workflow in parameters file

Alternatively to specifying workflow in the command-line using '-w' or '--workflow', workflow can be present as a parameter in parameters.csv file:
```
  workflow, parameter1, parameter2
  workflow.csv, value1, value2
```
# Lists of parameters


Parameters can be specified in several parameter files. To understand how 'list' parameter specification works, let's consider the case with 2 parameter files and 1 protocol.

parameters1.csv
```
  project , sample
  project1, sample1
  project1, sample2
  project1, sample3
```
parameters2.csv
```
  chr
  chr1
  chr2
  chr3
```
The example protocol looks like

protocol1.sh
```bash
  #!/bin/sh
  #string project
  #list sample
  #list chr
  for s in "${sample[@]}"
  do
    echo $s
    for c in "${chr[@]}"
    do
         echo $c
    done
  done
```
Here, 'sample' and 'chr' parameters are coming from 2 different parameter files. Both parameters are specified as 'list' in the protocol. These lists of parameters will not be combined, since they are coming from different parameters files.
The generated parameters lists will have the next look:
```bash
  #!/bin/sh
  #string project
  #list sample
  #list chr
  for s in "sample1" "sample2" "sample3"
  do
    echo $s
    for c in "chr1" "chr2" "chr3"
    do
         echo $c
    done
  done
```
If users want to combine lists that coming from separated files, lists should be declared on the same line, like
```bash
  list sample, chr
```
It will produce one list with all possible combination of parameters:
```
  sample1, chr1
  sample1, chr2
  sample1, chr3
  sample2, chr1
  sample2, chr2
  sample2, chr3
  sample3, chr1
  sample3, chr2
  sample3, chr3
```
It is not the desired behaviour in the considered protocol:
```bash
  #!/bin/sh
  #string project
  #list sample, chr
  for s in "sample1" "sample1" "sample1" "sample2" "sample2" "sample2" "sample3" "sample3" "sample3"
  do
    echo $s
    for c in "chr1" "chr2" "chr3" "chr1" "chr2" "chr3" "chr1" "chr2" "chr3"
    do
         echo $c
    done
  done
```