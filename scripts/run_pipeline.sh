#!/bin/bash
set -e

echo "======================================"
echo "Bacterial Variant Analysis Pipeline"
echo "======================================"

# Ensure script runs from project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
cd $PROJECT_DIR

DATA=$PROJECT_DIR/data
REF_DIR=$PROJECT_DIR/reference
QC=$PROJECT_DIR/qc
ALIGN=$PROJECT_DIR/alignment
VAR=$PROJECT_DIR/variants
ANN=$PROJECT_DIR/annotation
RES=$PROJECT_DIR/results
LOG=$PROJECT_DIR/logs

REF=$REF_DIR/reference.fasta
GFF=$REF_DIR/genes.gff
GENOME_NAME=user_genome

mkdir -p $QC $ALIGN $VAR $ANN $RES $LOG

########################################
# Check Input Files
########################################
echo "Checking input files..."

if ls $DATA/*.fastq.gz 1> /dev/null 2>&1; then
    echo "FASTQ files found"
else
    echo "ERROR: No FASTQ files found in data/ folder"
    exit 1
fi

if [ ! -f "$REF" ]; then
    echo "ERROR: reference/reference.fasta not found"
    exit 1
fi

if [ ! -f "$GFF" ]; then
    echo "WARNING: reference/genes.gff not found. Annotation may fail."
fi

########################################
# Step 1: FastQC
########################################
echo "Step 1: FastQC"
fastqc $DATA/*.fastq.gz -o $QC

########################################
# Step 2: Trimming
########################################
echo "Step 2: Trimming"
fastp \
-i $DATA/*_1.fastq.gz \
-I $DATA/*_2.fastq.gz \
-o $QC/trim_R1.fastq.gz \
-O $QC/trim_R2.fastq.gz \
-h $QC/fastp.html \
-j $QC/fastp.json

########################################
# Step 3: Index Reference
########################################
echo "Step 3: Index Reference"
if [ ! -f "$REF.bwt" ]; then
    bwa index $REF
fi

########################################
# Step 4: Alignment
########################################
echo "Step 4: Alignment"
bwa mem $REF \
$QC/trim_R1.fastq.gz \
$QC/trim_R2.fastq.gz > $ALIGN/aln.sam

########################################
# Step 5: SAM to BAM
########################################
echo "Step 5: SAM to BAM"
samtools view -S -b $ALIGN/aln.sam > $ALIGN/aln.bam

########################################
# Step 6: Sort BAM
########################################
echo "Step 6: Sort BAM"
samtools sort $ALIGN/aln.bam -o $ALIGN/aln.sorted.bam

########################################
# Step 7: Index BAM
########################################
echo "Step 7: Index BAM"
samtools index $ALIGN/aln.sorted.bam

########################################
# Step 8: Variant Calling
########################################
echo "Step 8: Variant Calling"
freebayes -f $REF \
$ALIGN/aln.sorted.bam > $VAR/variants.vcf

########################################
# Step 9: Filter Variants
########################################
echo "Step 9: Filter Variants"
bcftools filter -i 'QUAL>20' \
$VAR/variants.vcf > $VAR/variants.filtered.vcf

########################################
# Step 10: Build SnpEff Database
########################################
echo "Step 10: Preparing SnpEff database..."

SNPEFF_CONFIG=$(find $HOME -name "snpEff.config" | head -n 1)
SNPEFF_DATA_DIR=$(dirname $SNPEFF_CONFIG)/data

# Always rebuild database for new genome
rm -rf $SNPEFF_DATA_DIR/$GENOME_NAME
mkdir -p $SNPEFF_DATA_DIR/$GENOME_NAME

cp $REF $SNPEFF_DATA_DIR/$GENOME_NAME/sequences.fa
cp $GFF $SNPEFF_DATA_DIR/$GENOME_NAME/genes.gff

# Add genome entry if not exists
grep -q "$GENOME_NAME.genome" $SNPEFF_CONFIG || \
echo "$GENOME_NAME.genome : User Genome" >> $SNPEFF_CONFIG

echo "Building SnpEff database..."
snpEff build -gff3 -v $GENOME_NAME

########################################
# Step 11: Annotation
########################################
echo "Step 11: SnpEff Annotation"
snpEff ann $GENOME_NAME \
$VAR/variants.filtered.vcf > $ANN/variants.ann.vcf

########################################
# Step 12: Variant Table
########################################
echo "Step 12: Variant Table"
bcftools query \
-f '%CHROM\t%POS\t%REF\t%ALT\t%ANN\n' \
$ANN/variants.ann.vcf > $RES/variants.tsv

########################################
# Step 13: Variant Summary
########################################
echo "Step 13: Variant Summary"

echo "Total variants:" > $RES/variant_summary.txt
grep -v "^#" $VAR/variants.vcf | wc -l >> $RES/variant_summary.txt

echo "Filtered variants:" >> $RES/variant_summary.txt
grep -v "^#" $VAR/variants.filtered.vcf | wc -l >> $RES/variant_summary.txt

echo "SNPs:" >> $RES/variant_summary.txt
bcftools view -v snps $VAR/variants.filtered.vcf | grep -v "^#" | wc -l >> $RES/variant_summary.txt

echo "INDELs:" >> $RES/variant_summary.txt
bcftools view -v indels $VAR/variants.filtered.vcf | grep -v "^#" | wc -l >> $RES/variant_summary.txt

echo "======================================"
echo "Pipeline Completed Successfully"
echo "Results are in the results/ folder"
echo "======================================"