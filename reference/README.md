# Bacterial Variant Analysis Pipeline

This project provides a complete whole genome sequencing (WGS) variant analysis pipeline for bacterial genomes with a Streamlit web interface. The pipeline performs quality control, read trimming, alignment, variant calling, filtering, annotation, and generates variant tables and summary reports.

## Features
- FASTQ Quality Control using FastQC
- Read Trimming using fastp
- Genome Alignment using BWA
- BAM Processing using SAMtools
- Variant Calling using FreeBayes
- Variant Filtering using bcftools
- Variant Annotation using SnpEff
- Variant Table Generation
- Variant Summary Report
- Streamlit Web Application Interface
- Download Variant Results
- Docker Support

## Pipeline Workflow
FASTQ → FastQC → Trimming → Alignment → BAM → Variant Calling → Variant Filtering → Annotation → Variant Table → Summary Report → Streamlit Visualization

## Project Structure
bacterial-variant-analysis-pipeline/
│
├── streamlit_app/
│   └── app.py
├── scripts/
│   └── run_pipeline.sh
├── data/
├── reference/
├── qc/
├── alignment/
├── variants/
├── annotation/
├── results/
├── logs/
├── environment.yml
├── requirements.txt
├── Dockerfile
├── README.md
└── .gitignore

## Installation
Clone the repository and create the conda environment.

git clone https://github.com/YOUR_USERNAME/bacterial-variant-analysis-pipeline.git
cd bacterial-variant-analysis-pipeline
conda env create -f environment.yml
conda activate staph_variant_pipeline

## Reference Genome
This pipeline works for any bacterial genome.

Required reference files:
- reference.fasta (reference genome)
- genes.gff (gene annotation file for SnpEff)

Place reference files in:
reference/reference.fasta
reference/genes.gff

Index the reference before alignment:
bwa index reference/reference.fasta

Build SnpEff database before annotation.

## Input Data
Input files should be paired-end FASTQ files:
sample_1.fastq.gz
sample_2.fastq.gz

Place input FASTQ files in the data/ folder before running the pipeline.

## Running the Pipeline
Place FASTQ files in the data folder and reference genome in the reference folder, then run:

cd scripts
bash run_pipeline.sh

## Running the Streamlit App
cd streamlit_app
streamlit run app.py

Then open in browser:
http://localhost:8501

## Output Files
The pipeline generates the following results:
- variants.tsv (Variant table)
- variant_summary.txt (Variant statistics)
- snpEff_summary.html (Annotation report)
- variants.ann.vcf (Annotated variants)
- multiqc_report.html (QC report)

## Tools Used
FastQC
fastp
BWA
SAMtools
FreeBayes
bcftools
SnpEff
MultiQC
Streamlit
Python
Pandas
Docker

## Running with Docker
Build Docker image:
docker build -t bacterial-variant-pipeline .

Run the container:
docker run -p 8501:8501 bacterial-variant-pipeline

Open in browser:
http://localhost:8501

## Variant Pipeline Workflow Diagram
FASTQ Files
    ↓
FastQC (Quality Control)
    ↓
fastp (Trimming)
    ↓
BWA (Alignment)
    ↓
SAMtools (BAM Processing)
    ↓
FreeBayes (Variant Calling)
    ↓
bcftools (Variant Filtering)
    ↓
SnpEff (Variant Annotation)
    ↓
Variant Table + Summary
    ↓
Streamlit App (Visualization & Download)

## Author
Kiran Kumar
Bioinformatics | Genomics | Variant Analysis | AI in Biology