rule r_diffexp:
    input:
        counts_file=COUNTS_FILE,
        counts_log=COUNTS_LOG
    output:
        R_OUTPUTS
    params:
        scripts_dir=SCRIPTS_DIR,
        resources_dir=RESOURCES_DIR,
        outputs_dir=OUTPUTS_DIR
    conda:
        f'{ENVS_DIR}/r.yaml'
    priority: 1
    script:
        R_SCRIPT
