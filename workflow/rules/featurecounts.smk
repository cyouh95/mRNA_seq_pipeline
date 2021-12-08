rule featurecounts_count:
    input:
        g=ANNOTATION_FILE,
        bam=ALL_DEDUPED_BAM_FILES
    output:
        c=COUNTS_FILE,
        l=COUNTS_LOG
    conda:
        f'{ENVS_DIR}/featurecounts.yaml'
    priority: 1
    threads: 14
    shell:
        f'featureCounts -pC -T {{threads}} -g gene_id -t exon -a {{input.g}} -s {STRANDEDNESS} -o {{output.c}} {{input.bam}}'
