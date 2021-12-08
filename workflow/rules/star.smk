rule star_index:
    input:
        d=GENOME_FILE,
        g=ANNOTATION_FILE
    output:
        GENOME_INDEXED_FILE
    conda:
        f'{ENVS_DIR}/star.yaml'
    priority: 3
    threads: 14
    shell:
        f'STAR --runThreadN {{threads}} --runMode genomeGenerate --genomeDir {GENOME_DIR} --genomeFastaFiles {{input.d}} --sjdbGTFfile {{input.g}} --sjdbOverhang {SJDB_OVERHANG} --limitGenomeGenerateRAM 35000000000'

rule star_map:
    input:
        i=GENOME_INDEXED_FILE,
        f=TRIMMED_F_PAIRED_FILE,
        r=TRIMMED_R_PAIRED_FILE
    output:
        b=MAPPED_BAM_FILE,
        l=MAPPED_LOG_FILE
    conda:
        f'{ENVS_DIR}/star.yaml'
    priority: 2
    threads: 14
    shell:
        f'STAR --runThreadN {{threads}} --genomeDir {GENOME_DIR} --readFilesIn {{input.f}} {{input.r}} --readFilesCommand zcat --outFileNamePrefix {STAR_DIR}/{{wildcards.sample}}. --outSAMtype BAM Unsorted'
