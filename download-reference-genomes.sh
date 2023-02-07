#! /bin/bash

# download reference Genomes for specified Family or Genus from refseq database
# Family /Genus relation is defined by ncbi taxonomy (default) or change to gtdbtk
family=$1
mkdir -p 01_Download_Refseq_Genomes

# download gtdb metadata (needed because refseq summary does not contain full taxonomy)
wget -P 01_Download_Refseq_Genomes https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/bac120_metadata_r95.tar.gz
# unpack to file bac120_metadata_r95.tsv 
tar -xzvf 01_Download_Refseq_Genomes/bac120_metadata_r95.tar.gz
mv bac120_metadata_r95.tsv 01_Download_Refseq_Genomes/
# download bacterial refseq summary (needed because it contains FTP paths for creation of download links)
wget -P 01_Download_Refseq_Genomes https://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt
mv 01_Download_Refseq_Genomes/assembly_summary.txt 01_Download_Refseq_Genomes/assembly_summary_refseq.txt

# extract all genomes that belong to family according to taxonomy, chose column of desired taxonomy
# 	column 17: gtdb taxonomy
# 	column 79: ncbi taxonomy
# initiate table:
# head -1 bac120_metadata_r95.tsv > bacillaceae.tsv
# extract 
cut -f79 01_Download_Refseq_Genomes/bac120_metadata_r95.tsv | grep "f__$family" | grep -f - 01_Download_Refseq_Genomes/bac120_metadata_r95.tsv > 01_Download_Refseq_Genomes/${family}_gtdb.tsv
# count 
selected_from_gtdbtk=$(wc -l 01_Download_Refseq_Genomes/${family}_gtdb.tsv)
echo "There were $selected_from_gtdbtk potential references found in gtdbtk taxonomy file based on ncbi taxonomy"


# subset assembly summary for family of interest
# lookup the ftp base path in the genbank assembly summary. It is located in column 20 of assembly_summary.txt
# match using Genbank assembly accession from column 55
# cat bacillaceae.tsv | cut -f55 | grep -f - assembly_summary.txt | wc -l
cat 01_Download_Refseq_Genomes/${family}_gtdb.tsv | cut -f55 | grep -f - 01_Download_Refseq_Genomes/assembly_summary_refseq.txt > 01_Download_Refseq_Genomes/assembly_summary_${family}.tsv


# check for refseq exclusions (not reall neeed when using the refseq assembly summary 
# cut -f21 assembly_summary_bacillaceae.txt | sort | uniq


# grab ftb base from column 20 and edit to download links
cut -f20 01_Download_Refseq_Genomes/assembly_summary_${family}.tsv | while read ftp; do fname=$(echo $ftp | grep -o 'GCF_.*' ); echo $ftp/${fname}_genomic.fna.gz;done > 01_Download_Refseq_Genomes/${family}-refseq-download-links.txt
#wc -l ${family}-refseq-download-links.txt


#loop over links and dowload to Genomes Directory
mkdir 01_Download_Refseq_Genomes/Genomes
cat 01_Download_Refseq_Genomes/${family}-refseq-download-links.txt | while read line; do wget -P 01_Download_Refseq_Genomes/Genomes $line; done


# rename downloaded genomes: rename with strain name
# grab ftb base from column 20 and edit to download links, and get name for naming files 
cut -f8,20 01_Download_Refseq_Genomes/assembly_summary_${family}.tsv | sed 's\ \_\g'  | while read name ftp; do fname=$(echo $ftp | grep -o 'GCF_.*' ); mv 01_Download_Refseq_Genomes/Genomes/${fname}_genomic.fna.gz 01_Download_Refseq_Genomes/Genomes/${name}.fna.gz; done 

echo "Downloaded Genomes: $(ls 01_Download_Refseq_Genomes/Genomes/*fna.gz | wc -l)"
gzip -d 01_Download_Refseq_Genomes/Genomes/*fna.gz


