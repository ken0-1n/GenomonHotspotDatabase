#! /usr/bin/env python
import sys, os
import os.path

output_dir = sys.argv[1]
task_id = sys.argv[2]

if not os.path.exists(output_dir):
    os.mkdir(output_dir)

sorted_hotspot_list = []
fh = open(output_dir+"/refGene_hotspot."+task_id+".bed", "r")
for line in fh:
    sorted_hotspot_list.append(line)
fh.close()

sorted_hotspot_list = sorted(set(sorted_hotspot_list))

hOUT = open(output_dir + "/refGene_hotspot."+task_id+".anno", 'w')
for line in sorted_hotspot_list:
    line = line.rstrip('\n')
    F = line.split("\t")
    chr , pos = F[0].split(":")
    start , end = pos.split("-")
    start = str(int(start) + 1)
    for n in F[1]:
        if n not in ['A','C','G','T']: continue
        alt_list = ['A','C','G','T']
        alt_list.remove(n)
        for alt in alt_list:
            print >> hOUT, chr +"\t"+ start +"\t"+ start +"\t"+ n +"\t"+ alt
        start = str(int(start) + 1)
hOUT.close()

