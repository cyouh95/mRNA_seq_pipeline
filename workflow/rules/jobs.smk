rule jobs_summary:
    input:
        jobs_file=JOBS_FILE
    output:
        JOBS_OUTPUT
    conda:
        f'{ENVS_DIR}/r.yaml'
    script:
        JOBS_SCRIPT

rule jobs_info:
    input:
        MULTIQC_FILE,
        R_OUTPUTS
    output:
        JOBS_FILE
    shell:
        f"sacct -j $(ls {LOGS_DIR} | grep -v jobs | grep -oP '\d+(?=\.log)' | tr '\n' ',') -P --format='JobID,JobName,Start,End,Elapsed,MaxVMSize,NodeList,AllocNodes,AllocCPUS' > {JOBS_FILE}"
