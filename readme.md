# BUGflow DSL2
A bacterial sequencing data pipeline

## Overview
DSL2 version of Bug-flow DSL1: A pipeline for mapping followed by variant calling and de novo assembly of Illumina short read libraries. The pipeline is developed for use by the Modernising Medical Microbiology consortium, based at the University of Oxford.



The pipeline uses these tools:

#QC
 - Fastp
 - FastQC
 - MultiQC
 - Quast

#Mapping and Variant calling
 - snippy
 
#Assembly
 - shovill (spades and pilon) 

## Installation
Requires a local installation of 
* Docker - https://www.docker.com/get-started
* Java version 8 or later (required for nextflow)
* Nextflow - https://www.nextflow.io

### Clone the repository
Clone the repository locally
```
git clone https://github.com/davideyre/bug-flow.git
```

### Get the docker image
This can be pulled from docker hub
```
docker pull davideyre/bug-flow
```

Alternatively the docker image can be built from the Dockerfile. Within the cloned repository:
```
cd docker
docker build -t davideyre/bug-flow .
```
Note the tag has to match in the `nextflow.config` file.

## Running the the pipeline

Bug-flow DSL2 has subworkflows for screening and de novo assembly of short reads and accurately calling variants.

To clean and de novo assemble raw Illumina reads:

```
nextflow run main_bugflow_dsl2.nf -entry shovill --reads "[path-to-reads]/*{1,2}.fastq.gz" --outdir "[output_directory]"
```

To call high-quality SNPs from your reads:

```
nextflow run main_bugflow_dsl2.nf -entry shovill --reads "[path-to-reads]/*{1,2}.fastq.gz" --outdir "[output_directory]" --ref "[you_reference_sequence.fasta]"
```

### Running the subworkflows on example data

The "example_data" folder included in this repository contains 2 sets of fastq files.

```
cd example_data
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR334/008/SRR3349138/SRR3349138_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR334/008/SRR3349138/SRR3349138_2.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR334/004/SRR3349174/SRR3349174_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR334/004/SRR3349174/SRR3349174_2.fastq.gz
```
Screen and assemble the example reads

```
nextflow run main_bugflow_dsl2.nf -entry shovill --reads "./example_data/*{1,2}.fastq.gz" --outdir "Example_output"
```

Alternatively to resume a partially completed run where the intermediate files have been saved:
```
nextflow run main_bugflow_dsl2.nf -entry shovill --reads "./example_data/*{1,2}.fastq.gz" --outdir "Example_output" -resume
```



