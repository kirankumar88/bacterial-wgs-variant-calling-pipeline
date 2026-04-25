# Bacterial Variant Analysis Pipeline
Overview

This project provides a local web-based bacterial variant analysis pipeline for whole genome sequencing (WGS) data. The pipeline performs quality control, read trimming, alignment to a reference genome, variant calling, filtering, annotation, and generation of variant tables and summary reports. The pipeline is executed through a Streamlit web interface and runs locally.

This pipeline works for any bacterial genome using user-provided reference genome (FASTA) and annotation (GFF) files.

<img width="1693" height="929" alt="ChatGPT Image Apr 25, 2026, 10_15_38 AM" src="https://github.com/user-attachments/assets/faa4e1f7-d80e-4d74-8179-e8de43f0969b" />

-----------------------------------------
# Features
FASTQ Quality Control using FastQC
Read Trimming using fastp
Genome Alignment using BWA
BAM Processing using SAMtools
Variant Calling using FreeBayes
Variant Filtering using bcftools
Variant Annotation using SnpEff
Variant Table Generation
Variant Summary Report
Streamlit Web Application Interface
Download Variant Results
Docker Support
Works for any bacterial genome
-------------------------------------------
# Pipeline Workflow

FASTQ → FastQC → fastp → BWA → SAMtools → FreeBayes → bcftools → SnpEff → Variant Table → Summary Report → Streamlit Visualization
------------------------------------------
# Project Structure
bacterial-variant-analysis-pipeline/
│
├── streamlit_app/
│   └── app.py
├── scripts/
│   └── run_pipeline.sh
├── data/
│   └── README.md
├── reference/
│   └── README.md
├── results/
│   └── README.md
├── docs/
│   └── workflow.txt
├── Dockerfile
├── environment.yml
├── requirements.txt
├── streamlit.yaml
├── README.md
└── .gitignore
--------------------------------------------------------
# Requirements

Recommended environment: Linux or WSL

Required tools:

FastQC
fastp
BWA
SAMtools
FreeBayes
bcftools
SnpEff
Java
Python 3
Streamlit
Installation
-------------------------------------------------------
# Clone the repository and create the conda environment.

git clone https://github.com/kirankumar88/bacterial-wgs-variant-calling-pipeline.git
cd bacterial-variant-analysis-pipeline
conda env create -f environment.yml
conda activate bioinfo
---------------------------------
# Input Requirements

The following input files are required:

Paired-end FASTQ files (sample_1.fastq.gz, sample_2.fastq.gz)
Reference genome FASTA file
Annotation GFF file

Important:
The reference genome FASTA and annotation GFF file must correspond to the same bacterial genome and assembly version. Using mismatched FASTA and GFF files will result in incorrect variant annotation.
-----------------------------------------------------------
# Running the Pipeline (Command Line)

Place FASTQ files in the data/ folder and reference genome files in the reference/ folder, then run:

cd scripts
bash run_pipeline.sh

Results will be generated in the results/ folder.
--------------------------------------------
# Running the Streamlit App

Run the Streamlit application:

cd streamlit_app
streamlit run app.py
-----------------------------------------------
# Open in browser:

http://localhost:8501
------------------------------------------------------
# Upload:

R1 FASTQ
R2 FASTQ
Reference FASTA
GFF annotation file

Click Run Pipeline to start the analysis.
--------------------------------------------------
# Output Files

The pipeline generates the following output files:

variants.tsv – Variant table
variant_summary.txt – Variant statistics
variants.ann.vcf – Annotated variants
snpEff_summary.html – Annotation report
fastp.html – Trimming report
FastQC reports
Alignment and BAM files

All results are stored in the results/ folder.
---------------------------------------------------------
# SnpEff Configuration

This pipeline uses SnpEff for variant annotation.
For custom bacterial genomes, SnpEff requires a genome entry in the snpEff.config file.

The pipeline will attempt to automatically add a genome entry named:

user_genome.genome : User Genome

and build a SnpEff database using the uploaded reference genome (FASTA) and annotation file (GFF).
-----------------------------------------------------
# Troubleshooting

If you see the error:

java.lang.RuntimeException: Property not found in config file snpEff.config

You may need to manually add the genome entry to the SnpEff configuration file.

Locate snpEff.config:

find $HOME -name snpEff.config

Open the config file:

nano path/to/snpEff.config

Add this line at the end of the file:
user_genome.genome : User Genome

Then rebuild the database:

snpEff build -gff3 -v user_genome
Running with Docker
----------------------------------------------------
# Build Docker image:

docker build -t bacterial-variant-pipeline .
------------------------------------------------------
# Run the container:

docker run -p 8501:8501 bacterial-variant-pipeline
-----------------------------------------------------------
# Open in browser:
http://localhost:8501

--------------------------------------------------
# Tools Used
FastQC
fastp
BWA
SAMtools
FreeBayes
bcftools
SnpEff
Streamlit
Python
Pandas
Docker
Author
--------------------------------------------
# Kiran Kumar
Bioinformatics | Genomics | Variant Analysis | AI in Biology

