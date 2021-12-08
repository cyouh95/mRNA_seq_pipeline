rule multiqc_quality:
    input:
        ALL_FASTQC_FILES,
        ALL_TRIMMED_FASTQC_FILES,
        ALL_MAPPED_LOG_FILES,
        ALL_SORTED_BAM_QUALITY_FILES,
        ALL_DEDUPED_LOG_FILES,
        ALL_DEDUPED_BAM_QUALITY_FILES,
        COUNTS_LOG
    conda:
        f'{ENVS_DIR}/multiqc.yaml'
    output:
        MULTIQC_FILE
    shell:
        f'multiqc -n {MULTIQC_NAME} -c {MULTIQC_CONFIG_FILE} -o {MULTIQC_DIR} {{input}}'
