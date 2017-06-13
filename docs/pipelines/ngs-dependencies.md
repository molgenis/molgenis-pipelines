### 1) Dependency tree
```
- BWA (0.7.12)
- sambamba (v0.6.1)
- io_lib (1.14.6)
- Python (2.7.9)
- Zlib (1.2.8)
- bzip2 (1.0.6)
- libreadline (6.3)
	o ncursus (5.9)
- Picard
	o R(3.2.1-UMCG)
		• libreadline (6.3)
		• ncursus (5.9)
		• libjpeg-turbo (1.4.2)
		• NASM(2.11.08)
		• LibTIFF (4.0.4)
		• Tk (8.6.4)
			o Tcl (8.6.4.) 
				• Zlib (1.2.8)
		• cUrl (7.47.1)
		• libxml2 (2.9.2)
		• cairo (1.14.6)
			o bzip2 (1.0.6)
			o pixman (0.32.8)
			o fontconfig (2.11.94)
				• freetype (2.6.1)
					o libpng (1.6.21)
						• zlib (1.2.8)
					o expat (2.1.0)
		• PCRE (8.38)
		• Java (1.8.0_45)
	o Java (1.7.0_80)
- tabix(0.2.6)
- cutadapt (1.8.1)
- wkhtmltox (0.12.3)
- ngs-utils (16.05.1)
	o Text-CSV (1.33)
	o Log-Log4Perl (1.46)
- Molgenis-Compute (16.05.1)
- CmdLineAnnotator (1.9.0)
```

### 2) NGS_DNA-3.2.3 pipeline dependencies
```
('BWA','0.7.12-foss-2015b'),
('CmdLineAnnotator','1.9.0-Java-1.8.0_45')
('cutadapt-1.8.1-foss-2015b-Python-2.7.9'),
('delly','v0.7.1'),
('FastQC','0.11.3-Java-1.7.0_80'),
('GATK','3.5-Java-1.7.0_80'),
('io_lib','1.14.6-foss-2015b'),
('Java','1.8.0_45'),
('Molgenis-Compute','v16.05.1-Java-1.8.0_45'),
('ngs-utils','16.05.1'),
('picard','1.130-Java-1.7.0_80'),
('Python','2.7.9-foss-2015b'),
('R','3.2.1-foss-2015b'),
('sambamba','v0.6.1-foss-2015b'),
('SAMtools','1.2-foss-2015b'),
('snpEff','4.1g-Java-1.7.0_80'),
('tabix','0.2.6-foss-2015b'),
('wkhtmltox','0.12.3')
```