rule picard_sort:
    input:
        MAPPED_BAM_FILE
    output:
        SORTED_BAM_FILE
    conda:
        f'{ENVS_DIR}/picard.yaml'
    priority: 2
    shell:
        f'picard -Xmx5G SortSam I={{input}} O={{output}} SORT_ORDER={SORT_ORDER} TMP_DIR={TMP_DIR} CREATE_INDEX=true'

rule picard_dedupe:
    input:
        SORTED_BAM_FILE
    output:
        b=DEDUPED_BAM_FILE,
        l=DEDUPED_LOG_FILE
    conda:
        f'{ENVS_DIR}/picard.yaml'
    priority: 2
    shell:
        f'picard -Xmx5G MarkDuplicates I={{input}} O={{output.b}} M={{output.l}} TMP_DIR={TMP_DIR} REMOVE_DUPLICATES=true ASSUME_SORT_ORDER={SORT_ORDER} CREATE_INDEX=true'

rule picard_quality:
    input:
        SORTED_BAM_FILE
    output:
        SORTED_BAM_QUALITY_FILES
    conda:
        f'{ENVS_DIR}/picard.yaml'
    priority: 1
    shell:
        f'picard -Xmx5G CollectMultipleMetrics R={GENOME_FILE} I={{input}} O={PICARD_METRICS_DIR}/{{wildcards.sample}}_sorted PROGRAM=null PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectBaseDistributionByCycle PROGRAM=CollectInsertSizeMetrics PROGRAM=MeanQualityByCycle PROGRAM=QualityScoreDistribution PROGRAM=CollectGcBiasMetrics PROGRAM=RnaSeqMetrics REF_FLAT={REF_FLAT_FILE} TMP_DIR={TMP_DIR}'

rule picard_quality_deduped:
    input:
        DEDUPED_BAM_FILE
    output:
        DEDUPED_BAM_QUALITY_FILES
    conda:
        f'{ENVS_DIR}/picard.yaml'
    priority: 1
    shell:
        f'picard -Xmx5G CollectMultipleMetrics R={GENOME_FILE} I={{input}} O={PICARD_METRICS_DIR}/{{wildcards.sample}}_deduped PROGRAM=null PROGRAM=CollectAlignmentSummaryMetrics PROGRAM=CollectBaseDistributionByCycle PROGRAM=CollectInsertSizeMetrics PROGRAM=MeanQualityByCycle PROGRAM=QualityScoreDistribution PROGRAM=CollectGcBiasMetrics PROGRAM=RnaSeqMetrics REF_FLAT={REF_FLAT_FILE} TMP_DIR={TMP_DIR}'
