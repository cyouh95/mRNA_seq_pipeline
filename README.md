# mRNA-Sequencing Pipeline

This mRNA-sequencing pipeline was built to run on the San Jose State University (SJSU) High Performance Computer (HPC).

To run the pipeline using Slurm:

```
sbatch run_snakemake.sh
```

To clear all outputs between runs (_must follow [directory structure](#outputs)_):

```
snakemake -c1 clean
```


## Setup

Snakemake and mamba must be installed. To create a conda environment with the required packages:

```
conda create -n bfx_env python=3.8

conda install snakemake
conda install -c conda-forge mamba
```

The specific versions used in this project were:

- Python (v._3.8.12_)
- Snakemake (v._6.10.0_)
- Mamba (v._0.17.0_)


## Configs

Update the following configuration files:

- `config/`
  - **[config.yaml](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/config/config.default.yaml)**: Contains settings for the Snakemake workflow (_used in [`workflow/Snakefile`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/workflow/Snakefile)_)
  - **[multiqc_config.yaml](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/config/multiqc_config.default.yaml)**: Contains settings for the MultiQC report (_used in [`config/config.yaml`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/config/config.default.yaml)_)
- `slurm/`
  - **[config.yaml](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/slurm/config.yaml)**: Contains settings for running the pipeline using Slurm (_used in [`run_snakemake.sh`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/run_snakemake.sh)_)
  - **[cluster.yaml](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/slurm/cluster.default.yaml)**: Contains settings for job submissions (_used in [`slurm/config.yaml`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/slurm/config.yaml)_)


## Outputs

The outputs folder, specified by **outputs_dir** in [`config/config.yaml`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/config/config.default.yaml), should have the following directory structure:

```
/path/to/outputs
├── fastqc
├── featurecounts
├── logs
├── multiqc
├── picard
├── picard_metrics
├── r
├── star
└── trimmomatic
```

## Resources

All resources, including data and reference genome, must be placed inside the **resources** folder. Filepaths are written relative to it when specified in [`config/config.yaml`](https://github.com/cyouh95/mRNA_seq_pipeline/blob/main/config/config.default.yaml).
