
Requires
----------

An UGE cluster environment

Dependecy
----------

software
* [bedtools](https://code.google.com/p/bedtools/)
* [ANNOVAR](http://annovar.openbioinformatics.org/en/latest/user-guide/download/)

database
* [refGene.txt from the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)
* [ensemblToGeneName.txt from the UCSC site](http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/)
* [CosmicMutantExport.tsv from the COSMIC FTP site](http://cancer.sanger.ac.uk/cosmic/download)
* GRCh37-lite.fa
  ftp://ftp.ncbi.nih.gov/genomes/archive/old_genbank/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh37/special_requests/
* The database/statistically_significant_hotspot.txt was created from the following table:    
  [Identifying recurrent mutations in cancer reveals widespread lineage diversity and mutational specificity](http://www.nature.com/nbt/journal/v34/n2/full/nbt.3391.html) Chang, M.T. et al, Nature Biotechnology, 2016.
  Supplementary Table 2: Summary of statistically significant hotspot mutations


SetUp
----------

1. Download the software.
    $ git clone https://github.com/ken0-1n/GenomonHotspotDatabase.git
    
2. Download database
```
$ cd GenomonHotspotDatabase/database
# Download refGene.txt
$ wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/refGene.txt.gz 
$ gunzip refGene.txt.gz
# Download ensemblToGeneName.txt
$ wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/database/ensemblToGeneName.txt.gz
$ gunzip ensemblToGeneName.txt.gz
# Download CosmicMutantExport.tsv
# Please visit http://cancer.sanger.ac.uk/cosmic/help/download
# Download /cosmic/grch37/cosmic/{version}/CosmicMutantExport.tsv.gz
$ gunzip CosmicMutantExport.tsv.gz
```

3. Download ANNOVAR database   
```
$ cd $annovar_dir
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene humandb/  
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar ensGene humandb/  
$ ./annotate_variation.pl -buildver hg19 -downdb -webfrom annovar knownGene humandb/  
```

4. Open scripts/make_hotspot_info.sh and set each entry.  
    REF_GENE_BED="The path to to the refGene.coding.exon.151207.bed"  
    BEDTOOLS="The path to the bedtools-2.24.0/bin/bedtools"  
    GRCH37="The path to the GRCh37.fa"  
    ANNOVAR_DIR="The path to the annovar"  
    ENSEMBLE_GENE="The path to the ensemblToGeneName.txt"  
    COSMIC_MUTATNT="The path to the CosmicMutantExport.tsv"  
    HOTSPOT_LIST="the path to the statistically_significant_hotspot.txt"  

Run
---

Use the following command

    $ bash ./make_hotspot_info.sh logdir outputdir
    
