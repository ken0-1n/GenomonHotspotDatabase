#! /usr/bin/env python
import sys, os
import os.path

output_dir = sys.argv[1]
task_id = sys.argv[2]

if not os.path.exists(output_dir):
    os.mkdir(output_dir)

new_gene_list = []
refGene = output_dir+"/"+task_id+".txt"
fh = open(refGene, "r")
for line in fh:
    line = line.rstrip('\n')
    F = line.split('\t')
    chr = F[0]
    chr = chr.replace("chr", "")
    start = F[1]
    end = F[2]
    genes = F[3]
    gene_list = genes.split(";")
    for gene_info in gene_list:
        gene = gene_info.split("(")[0]
        new_gene_list.append(chr +"\t"+ start +"\t"+ end +"\t"+ gene)
fh.close()

new_gene_list = sorted(set(new_gene_list))

hOUT = open(output_dir + "/refGene_tmp."+task_id+".bed", 'w')
for v in new_gene_list:
   print >> hOUT, v
hOUT.close()

