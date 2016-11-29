#! /bin/bash

PATH_TO_BEDTOOLS=$1

if [ $# -ne 1 ]; then
    echo "Usage: bash $0 {path_to_bed_tools}"
    exit 1
fi

export PATH=${PATH_TO_BEDTOOLS}:${PATH}

rm -rf refGene.txt.gz
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/refGene.txt.gz

python ref_seq2bed.py refGene.txt.gz || exit ?

echo "sortBed -i refGene.coding.tmp.bed | mergeBed -i stdin -c 4 -o collapse > refGene.coding.bed"
sortBed -i refGene.coding.tmp.bed | mergeBed -i stdin -c 4 -o collapse > refGene.coding.bed
if [ ${PIPESTATUS[0]} -gt 0 -a ${PIPESTATUS[1]} -gt 0 ]; then
    exit 1
fi

rm refGene.coding.tmp.bed

rm -rf ensemblToGeneName.txt.gz ensemblToGeneName.txt
wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/ensemblToGeneName.txt.gz
gunzip ensemblToGeneName.txt.gz

