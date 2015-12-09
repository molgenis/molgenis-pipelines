Patrick Deelen
Morris A. Swertz
University of Groningen, University Medical Center Groningen, Genomics Coordination Center, Groningen, the Netherlands
University of Groningen, University Medical Center Groningen, Department of Genetics, Groningen, the Netherlands
Please use both affiliations

Gene expression quantification
The trimmed fastQ files where aligned to build 37 human reference genome using STAR 2.3.1 [1] allowing for 2 mismatches. 
Before gene quantification SAMtools 0.1.18 [2] was used to sort the aligned reads. 
The gene level quantification was performed by HTSeq-0.5.4 [3] using --mode=union --stranded=no and,
Ensembl version 71 was used as gene annotation database.

1. Dobin A, Davis C a, Schlesinger F, Drenkow J, Zaleski C, Jha S, Batut P, Chaisson M,
Gingeras TR: STAR: ultrafast universal RNA-seq aligner. Bioinformatics 2013, 29:15–21.
2. Li H, Handsaker B, Wysoker A, Fennell T, Ruan J, Homer N, Marth G, Abecasis G, Durbin R,
Subgroup 1000 Genome Project Data Processing: The Sequence Alignment/Map format and SAMtools.
Bioinforma 2009, 25 (16 ):2078–2079.
3. Anders S, Pyl PT, Huber W: HTSeq – A Python framework to work with high-throughput sequencing data
HTSeq – A Python framework to work with high-throughput sequencing data. 2014:0–5.
