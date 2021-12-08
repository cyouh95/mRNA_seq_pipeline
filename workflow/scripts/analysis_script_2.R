library(tidyverse)


scripts_dir <- snakemake@params[['scripts_dir']]
resources_dir <- snakemake@params[['resources_dir']]
genesets_dir <- file.path(resources_dir, 'genesets')


# -----------------
# Load counts data 
# -----------------

meta_data <- read_csv(file.path(resources_dir, 'PRJNA748404_meta.txt')) %>% 
  mutate(treatment = recode(treatment, 'counterpart' = 'control', 'post treatment 16 weeks' = 'diabetes'))


# Project data
data_project <- read_tsv(snakemake@input[['counts_file']], skip = 1)
sample_names <- sub('.+(SRR\\d+)_(?:sorted|deduped)\\.bam', '\\1', names(data_project)) %>% gsub(pattern = '\\.', replacement = '_')
names(data_project) <- sample_names


# ----------------
# Load other data
# ----------------

# Genesets data
mm_ensembl_entrez <- readRDS(file.path(genesets_dir, 'mm_ensembl_entrez.GRCm38.p6.RDS'))
mm_ensembl_symbol <- readRDS(file.path(genesets_dir, 'mm_ensembl_symbol.GRCm38.p6.RDS'))

mm_h <- readRDS(file.path(genesets_dir, 'Mm.h.all.v7.1.entrez.rds'))
mm_c5_bp <- readRDS(file.path(genesets_dir, 'Mm.c5.bp.v7.1.entrez.rds'))
mm_c5_cc <- readRDS(file.path(genesets_dir, 'Mm.c5.cc.v7.1.entrez.rds'))
mm_c5_mf <- readRDS(file.path(genesets_dir, 'Mm.c5.mf.v7.1.entrez.rds'))


# ----------------
# Prep input data
# ----------------

# Meta data
col_data <- meta_data %>% select(Run, treatment) %>% mutate(label = treatment)
col_data$treatment <- factor(col_data$treatment, levels = c('control', 'diabetes'))


# Counts data
counts_project <- data.frame(data_project %>% select(contains('SRR')), row.names = data_project$Geneid)
counts_project <- data.frame(data_project %>% select(contains('SRR')), row.names = data_project$Geneid)


# -----------------
# Generate reports
# -----------------

params_default <- list(
  mm_ensembl_entrez = mm_ensembl_entrez,
  mm_ensembl_symbol = mm_ensembl_symbol,
  mm_h = mm_h,
  mm_c5_bp = mm_c5_bp,
  mm_c5_cc = mm_c5_cc,
  mm_c5_mf = mm_c5_mf
)


# Project data
rmarkdown::render(
  input = file.path(scripts_dir, 'analysis_report.Rmd'),
  output_file = snakemake@output[[1]],
  params = c(
    params_default,
    col_data = list(col_data),
    counts_data = list(counts_project),
    condition = 'diabetes',
    control = 'control',
    lfc_cutoff = 0.585,
    genes_length = list(data_project$Length),
    use_fpkm = T
  )
)


# Summary
rmarkdown::render(
  input = file.path(scripts_dir, 'summary_report.Rmd'),
  output_file = snakemake@output[[2]],
  params = c(
    meta_data = list(meta_data),
    dir_name = snakemake@params[['outputs_dir']],
    counts_log = snakemake@input[['counts_log']],
    fig_height = 2.4
  )
)
