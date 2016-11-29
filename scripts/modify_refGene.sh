#!/bin/bash
#
# Set SGE
#
#$ -S /bin/bash         # set shell in UGE
#$ -cwd                 # execute at the submitted dir
#$ -l s_vmem=14.1G,mem_req=14.1G
pwd                     # print current working directory
hostname                # print hostname
date                    # print date

num=$((${SGE_TASK_ID} - 1))
file_number=$(printf "%04d" ${num})

OUTPUT_DIR=$1
BEDTOOLS=$2
REF_FASTA=$3
ANNOVAR_DIR=$4

echo "python modify_refGene_coding.py $OUTPUT_DIR ${file_number}"
python modify_refGene_coding.py  $OUTPUT_DIR $file_number || exit $?

echo "${BEDTOOLS} getfasta -fi ${REF_FASTA} -bed ${OUTPUT_DIR}/refGene_tmp.${file_number}.bed -fo ${OUTPUT_DIR}/refGene_hotspot.${file_number}.bed -tab"
${BEDTOOLS} getfasta -fi ${REF_FASTA} -bed ${OUTPUT_DIR}/refGene_tmp.${file_number}.bed -fo ${OUTPUT_DIR}/refGene_hotspot.${file_number}.bed -tab || exit $?

echo "python modify_refGene_hotspot.py  $OUTPUT_DIR $file_number"
python modify_refGene_hotspot.py  $OUTPUT_DIR $file_number || exit $?

echo "${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/refGene_hotspot.${file_number} -buildver hg19 -remove -protocol refGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb"
${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/refGene_hotspot.${file_number} -buildver hg19 -remove -protocol refGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb || exit $?

echo "${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/ensGene_hotspot.${file_number} -buildver hg19 -remove -protocol ensGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb"
${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/ensGene_hotspot.${file_number} -buildver hg19 -remove -protocol ensGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb || exit $?

echo "${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/knownGene_hotspot.${file_number} -buildver hg19 -remove -protocol knownGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb"
${ANNOVAR_DIR}/table_annovar.pl --outfile ${OUTPUT_DIR}/knownGene_hotspot.${file_number} -buildver hg19 -remove -protocol knownGene -operation g ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno ${ANNOVAR_DIR}/humandb || exit $?

rm ${OUTPUT_DIR}/${file_number}.txt
rm ${OUTPUT_DIR}/refGene_tmp.${file_number}.bed
rm ${OUTPUT_DIR}/refGene_hotspot.${file_number}.bed
rm ${OUTPUT_DIR}/refGene_hotspot.${file_number}.anno


