#!/bin/bash
#
#SBATCH --job-name=run_snakemake
#SBATCH --output=results/logs/%x-%j.log
#
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=48:00:00
#SBATCH --mem-per-cpu=20000

time snakemake --profile slurm
