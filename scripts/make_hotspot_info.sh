#!/bin/bash
#
# Set SGE
#
#$ -S /bin/bash         # set shell in UGE
#$ -cwd                 # execute at the submitted dir

LOGDIR=$1
OUTPUTDIR=$2
REF_GENE_BED="../database/refGene.coding.exon.bed"
ENSEMBLE_GENE="../database/ensemblToGeneName.txt"
COSMIC_MUTATNT="../database/CosmicMutantExport.tsv"
HOTSPOT_LIST="../database/hotspots.txt"
BEDTOOLS="../tools/bedtools-2.24.0/bin/bedtools"
GRCH37="../database/GRCh37/GRCh37.fa"
ANNOVAR_DIR="../tools/annovar"

if [ $# -ne 2 ]; then
  echo "wrong number of arguments"
  echo "usage: $0 logdir outputdir"
  exit 1
fi

mkdir -p $OUTPUTDIR $LOGDIR

if [ ! -f ${REF_GENE_BED} ]; then
    echo "${REF_GENE_BED} not found."
    exit 1
fi
if [ ! -f ${BEDTOOLS} ]; then
    echo "${BEDTOOLS} not found."
    exit 1
fi
if [ ! -f ${GRCH37} ]; then
    echo "${GRCH37} not found."
    exit 1
fi
if [ ! -f "${ANNOVAR_DIR}/table_annovar.pl" ]; then
    echo "${ANNOVAR_DIR}table_annovar.pl not found."
    exit 1
fi
if [ ! -f ${ENSEMBLE_GENE} ]; then
    echo "${ENSEMBLE_GENE} not found."
    exit 1
fi
if [ ! -f ${COSMIC_MUTATNT} ]; then
    echo "${COSMIC_MUTATNT} not found."
    exit 1
fi
if [ ! -f ${HOTSPOT_LIST} ]; then
    echo "${HOTSPOT_LIST} not found."
    exit 1
fi

# cat $REF_GENE_BED | split -a 4 -d -l 1 - "${OUTPUTDIR}/"
cat $REF_GENE_BED | split -a 4 -d -l 100 - "${OUTPUTDIR}/"
if [ ${PIPESTATUS[0]} -gt 0 -a ${PIPESTATUS[1]} -gt 0 ]; then
    exit 1
fi

count=0
for filename in `ls -1 ${OUTPUTDIR}/[0-9][0-9][0-9][0-9]`; do
  mv $filename $filename.txt
  count=$(( count + 1 ))
done

qsub -sync yes -t 1-${count}:1 -e $LOGDIR -o $LOGDIR modify_refGene.sh $OUTPUTDIR $BEDTOOLS $GRCH37 $ANNOVAR_DIR || exit $?

count=$(( count - 1 ))

echo -n > ${OUTPUTDIR}/refGene_hotspot.hg19_multianno.txt
for i in `seq 0 ${count}`; do
    j=$(printf "%04d" ${i})
    awk '{if(NR>1){print $0}}' ${OUTPUTDIR}/refGene_hotspot.${j}.hg19_multianno.txt >> ${OUTPUTDIR}/refGene_hotspot.hg19_multianno.txt
    echo "rm ${OUTPUTDIR}/refGene_hotspot.${j}.hg19_multianno.txt"
    rm ${OUTPUTDIR}/refGene_hotspot.${j}.hg19_multianno.txt
done

echo -n > ${OUTPUTDIR}/ensGene_hotspot.hg19_multianno.txt
for i in `seq 0 ${count}`; do
    j=$(printf "%04d" ${i})
    awk '{if(NR>1){print $0}}' ${OUTPUTDIR}/ensGene_hotspot.${j}.hg19_multianno.txt >> ${OUTPUTDIR}/ensGene_hotspot.hg19_multianno.txt
    echo "rm ${OUTPUTDIR}/ensGene_hotspot.${j}.hg19_multianno.txt"
    rm ${OUTPUTDIR}/ensGene_hotspot.${j}.hg19_multianno.txt
done

echo -n > ${OUTPUTDIR}/knownGene_hotspot.hg19_multianno.txt
for i in `seq 0 ${count}`; do
    j=$(printf "%04d" ${i})
    awk '{if(NR>1){print $0}}' ${OUTPUTDIR}/knownGene_hotspot.${j}.hg19_multianno.txt >> ${OUTPUTDIR}/knownGene_hotspot.hg19_multianno.txt
    echo "rm ${OUTPUTDIR}/knownGene_hotspot.${j}.hg19_multianno.txt"
    rm ${OUTPUTDIR}/knownGene_hotspot.${j}.hg19_multianno.txt
done

python add_genomon_mutation_position.py ${HOTSPOT_LIST} ${OUTPUTDIR}/refGene_hotspot.hg19_multianno.txt ${OUTPUTDIR}/ensGene_hotspot.hg19_multianno.txt ${OUTPUTDIR}/knownGene_hotspot.hg19_multianno.txt $ENSEMBLE_GENE $COSMIC_MUTATNT $OUTPUTDIR




