#! /usr/bin/env python
import sys
import re

hotspot_list = sys.argv[1]
refGene = sys.argv[2]
ensGene = sys.argv[3]
knownGene = sys.argv[4]
ensemblToGeneName = sys.argv[5]
cosmic_list = sys.argv[6]
output_dir = sys.argv[7]

def complementSeq(seq):

    tseq = seq[::-1];

    tseq = tseq.replace("A","S")
    tseq = tseq.replace("T","A")
    tseq = tseq.replace("S","T")

    tseq = tseq.replace("C","S")
    tseq = tseq.replace("G","C")
    tseq = tseq.replace("S","G")

    return tseq

ens_name_dict = {}
hIN = open(ensemblToGeneName, 'r')
for line in hIN:
    line = line.rstrip('\r\n')
    F = line.split('\t')
    ens_name_dict[F[0]] = F[1]
hIN.close()

hotspot_dict = {}
hIN = open(hotspot_list, 'r')
hHeader = hIN
for line in hIN:
    line = line.rstrip('\r\n')
    F = line.split('\t')
    symbol = F[0]
    codon = F[1]
    amino_acids = F[2].split("|")
    q_value = F[3]
    tumor_count = F[4]
    tumor_type_count = F[5]

    for amino_acid_info in amino_acids:
        aa_list = amino_acid_info.split(":")
        tmp_aa = aa_list[0].replace("*","X")
        aa = "p." + codon + tmp_aa
        hotspot_dict[symbol + "\t" + aa] = q_value +"\t"+ tumor_count + "\t"+ tumor_type_count
        flg = False

hIN.close()

hOUT = open(output_dir + "/refGene_hotspot.txt", 'w')
gene_list = [refGene, knownGene]
source_list = ["refGene","knownGene"]
for filename in gene_list:
    hIN = open(filename, 'r')
    for line in hIN:
    
        line = line.rstrip('\n')
        F = line.split('\t')
        chr = F[0]
        start = F[1]
        end = F[2]
        ref = F[3]
        alt = F[4]
        aa_change = F[9]
    
        if aa_change != "":
            aa_info_list = aa_change.split(",")
            for aa_info in aa_info_list:
                aa_list = aa_info.split(":")
                if len(aa_list) == 5:
                    gene_name = aa_list[0]
                    uid = aa_list[1]
                    codon= aa_list[3]
                    protein= aa_list[4]
                    key = gene_name + "\t" + protein
                    if key in hotspot_dict:
                        print >> hOUT, chr +"\t"+ start +"\t"+ end +"\t"+ ref +"\t"+ alt +"\t"+ gene_name +"\t"+ codon +"\t"+ protein +"\t"+hotspot_dict[key] +"\t"+ uid
                        del hotspot_dict[key]
    hIN.close()

hIN = open(ensGene, 'r')
for line in hIN:

    line = line.rstrip('\n')
    F = line.split('\t')
    chr = F[0]
    start = F[1]
    end = F[2]
    ref = F[3]
    alt = F[4]
    aa_change = F[9]

    if aa_change != "":
        aa_info_list = aa_change.split(",")
        for aa_info in aa_info_list:
            aa_list = aa_info.split(":")
            if len(aa_list) == 5:
                uid = aa_list[1]
                if uid in ens_name_dict:
                    gene_name = ens_name_dict[uid]
                    codon= aa_list[3]
                    protein= aa_list[4]
                    key = gene_name + "\t" + protein
                    if key in hotspot_dict:
                        print >> hOUT, chr +"\t"+ start +"\t"+ end +"\t"+ ref +"\t"+ alt +"\t"+ gene_name +"\t"+ codon +"\t"+ protein +"\t"+hotspot_dict[key] +"\t"+ uid
                        del hotspot_dict[key]


r = re.compile("c.([0-9]+_*[0-9]*)([A-Z]+)>([A-Z]+)")
g = re.compile("(\w*)_ENST[0-9]+")
hIN = open(cosmic_list, 'r')
for line in hIN:
    F = line.rstrip('\n').split('\t')
    gene_name = F[0]
    mutation_position = F[23]
    mutation_cds = F[17]
    protein = F[18]
    uid = F[16]
    mutation_strand = F[24]
    tmp_gene_list = g.findall(gene_name)
    if len(tmp_gene_list) == 1 and tmp_gene_list[0] != "":
        gene_name = tmp_gene_list[0]
    key = gene_name + "\t" + protein
    if key in hotspot_dict:
        if  mutation_position != "":
            chr, pos = mutation_position.split(":")
            start, end = pos.split("-")
            ref_alt_list = r.findall(mutation_cds)
            if len(ref_alt_list) == 1 and len(ref_alt_list[0]) == 3:
                ref = ref_alt_list[0][1]
                alt = ref_alt_list[0][2]
                codon = "c." + ref + ref_alt_list[0][0] + alt
                if mutation_strand == "-":
                    ref = complementSeq(ref)
                    alt = complementSeq(alt)
                print >> hOUT, chr +"\t"+ start +"\t"+ end +"\t"+ ref +"\t"+ alt +"\t"+ gene_name +"\t"+ codon +"\t"+ protein +"\t"+hotspot_dict[key] +"\t"+ uid
                del hotspot_dict[key]

hIN.close()
hOUT.close()

hOUT = open(output_dir + "/refGene_hotspot_error.txt", 'w')
for v in hotspot_dict:
  print >> hOUT, v
hOUT.close()
