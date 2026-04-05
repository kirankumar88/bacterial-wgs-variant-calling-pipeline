import streamlit as st
import subprocess
import os
import pandas as pd

st.info("""
Important:
Reference genome FASTA, GFF annotation file, and SnpEff database must match the same bacterial genome.
Using mismatched files will result in incorrect variant annotation.
""")

st.set_page_config(page_title="Bacterial Variant Analysis Pipeline", layout="wide")

st.title("Bacterial Variant Analysis Pipeline")


st.sidebar.header("Pipeline Workflow")
st.sidebar.write("""
1. FastQC
2. fastp (Trimming)
3. BWA Alignment
4. BAM Processing
5. Variant Calling (FreeBayes)
6. Variant Filtering
7. Annotation (SnpEff)
8. Variant Table & Summary
""")

st.header("Upload Input Files")

col1, col2 = st.columns(2)
with col1:
    fastq1 = st.file_uploader("Upload R1 FASTQ", type=["fastq", "gz"])
with col2:
    fastq2 = st.file_uploader("Upload R2 FASTQ", type=["fastq", "gz"])

ref_file = st.file_uploader("Upload Reference Genome (FASTA)", type=["fa", "fasta"])
gff_file = st.file_uploader("Upload Annotation File (GFF)", type=["gff", "gff3"])

if st.button("Run Variant Pipeline"):
    if fastq1 and fastq2 and ref_file:

        project_dir = os.path.expanduser("~/final_variant_project")
        data_dir = os.path.join(project_dir, "data")
        ref_dir = os.path.join(project_dir, "reference")
        results_dir = os.path.join(project_dir, "results")
        script_path = os.path.join(project_dir, "scripts/run_pipeline.sh")

        os.makedirs(data_dir, exist_ok=True)
        os.makedirs(ref_dir, exist_ok=True)
        os.makedirs(results_dir, exist_ok=True)

        # Save FASTQ
        with open(os.path.join(data_dir, "sample_1.fastq.gz"), "wb") as f:
            f.write(fastq1.getbuffer())

        with open(os.path.join(data_dir, "sample_2.fastq.gz"), "wb") as f:
            f.write(fastq2.getbuffer())

        # Save reference genome
        with open(os.path.join(ref_dir, "reference.fasta"), "wb") as f:
            f.write(ref_file.getbuffer())

        # Save GFF if provided
        if gff_file:
            with open(os.path.join(ref_dir, "genes.gff"), "wb") as f:
                f.write(gff_file.getbuffer())

        st.subheader("Running Pipeline...")
        subprocess.run(["bash", script_path])
        st.success("Pipeline Completed")

        # Show results
        st.header("Pipeline Results")

        if os.path.exists(results_dir):
            st.write("Files in results folder:")
            st.write(os.listdir(results_dir))

        summary_file = os.path.join(results_dir, "variant_summary.txt")
        tsv_file = os.path.join(results_dir, "variants.tsv")

        if os.path.exists(summary_file):
            st.subheader("Variant Summary")
            with open(summary_file) as f:
                st.text(f.read())
        else:
            st.warning("Variant summary not found")

        if os.path.exists(tsv_file):
            st.subheader("Variant Table")
            df = pd.read_csv(tsv_file, sep="\t")
            st.dataframe(df)

            # Plot variant types
            if "TYPE" in df.columns:
                st.subheader("Variant Type Distribution")
                st.bar_chart(df["TYPE"].value_counts())

            with open(tsv_file, "rb") as file:
                st.download_button(
                    label="Download Variant Table",
                    data=file,
                    file_name="variants.tsv"
                )
        else:
            st.warning("Variant table not found")

    else:
        st.warning("Please upload FASTQ files and Reference Genome.")