
Requires
----------

An UGE cluster environment

Dependecy
----------

software
* [bedtools](https://code.google.com/p/bedtools/)
* [ANNOVAR](http://annovar.openbioinformatics.org/en/latest/user-guide/download/)

database
* The database/statistically_significant_hotspot.txt was created from the following table:    
  [Identifying recurrent mutations in cancer reveals widespread lineage diversity and mutational specificity](http://www.nature.com/nbt/journal/v34/n2/full/nbt.3391.html) Chang, M.T. et al, Nature Biotechnology, 2016.
  Supplementary Table 2: Summary of statistically significant hotspot mutations


SetUp
----------

1. Download the software.
```
$ git clone https://github.com/ken0-1n/GenomonHotspotDatabase.git
$ git clone https://github.com/ken0-1n/RefGeneTxtToBed.git
```

2. Download database
```
$ cd GenomonHotspotDatabase/database

# Download ensemblToGeneName.txt
$ wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/ensemblToGeneName.txt.gz
$ gunzip ensemblToGeneName.txt.gz

# Download CosmicMutantExport.tsv
# Please visit http://cancer.sanger.ac.uk/cosmic/help/download
# Download /cosmic/grch37/cosmic/{version}/CosmicMutantExport.tsv.gz
$ gunzip CosmicMutantExport.tsv.gz

# Download refGene.txt
$ wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/refGene.txt.gz 
$ cd RefGeneTxtToBed
$ python ref_seq2bed.py GenomonHotspotDatabase/database/refGene.txt.gz /home/kchiba/tools/bedtools
```

3. Download ANNOVAR database   
```
$ cd {annovar_dir}
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/  
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar ensGene humandb/  
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar knownGene humandb/  
```

4. Open make_hotspot_info.sh and set each entry.  
```
 $ vi GenomonHotspotDatabase/scripts/make_hotspot_info.sh
 
 10 REF_GENE_BED="The path to to the refGene.coding.exon.bed"  
 11 BEDTOOLS="The path to the bedtools-2.XX.X/bin/bedtools"  
 12 GRCH37="The path to the GRCh37.fa"  
 13 ANNOVAR_DIR="The path to the annovar"  
 14 ENSEMBLE_GENE="The path to the ensemblToGeneName.txt"  
 15 COSMIC_MUTATNT="The path to the CosmicMutantExport.tsv"  
 16 HOTSPOT_LIST="the path to the statistically_significant_hotspot.txt"  
```

Run
---

Use the following command
```
 cd GenomonHotspotDatabase/scripts
 $ bash ./make_hotspot_info.sh logdir outputdir
```
