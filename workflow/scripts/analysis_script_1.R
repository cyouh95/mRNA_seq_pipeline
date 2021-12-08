library(tidyverse)


scripts_dir <- snakemake@params[['scripts_dir']]
resources_dir <- snakemake@params[['resources_dir']]
data_dir <- file.path(resources_dir, 'data_1_paper')
genesets_dir <- file.path(resources_dir, 'genesets')


# -----------------
# Load counts data 
# -----------------

meta_data <- read_csv(file.path(resources_dir, 'PRJNA694971_meta.txt')) %>%
  arrange(experimental_class_type, Run)


# Paper data
counts_files <- list.files(data_dir)

data_paper <- read_tsv(file.path(data_dir, counts_files[1])) %>% select(-EU181)

for (counts_file in counts_files) {
  m <- str_match(counts_file, '(GSM\\d+)_(EU\\d+)')
  run_id <- meta_data[meta_data$`Sample Name` == m[, 2], ]$Run
  
  tmp_df <- read_tsv(file.path(data_dir, counts_file)) %>%
    dplyr::rename(!!run_id := m[, 3]) %>%
    select(Geneid, !!run_id)
  
  data_paper <- data_paper %>% left_join(tmp_df, by = 'Geneid')
}


# Project data
data_project <- read_tsv(snakemake@input[['counts_file']], skip = 1)
sample_names <- sub('.+(SRR\\d+)_(?:deduped|sorted)\\.bam', '\\1', names(data_project)) %>% gsub(pattern = '\\.', replacement = '_')
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
col_data <- meta_data %>% select(-treatment, Run, experimental_class_type, regime) %>% dplyr::rename('treatment' = 'experimental_class_type', 'label' = 'regime')
col_data$treatment <- factor(col_data$treatment, levels = c('E', 'C', 'A'))
col_data$label <- factor(col_data$label, levels = c('on land', 'in space with gravity', 'in space without gravity'))


# Counts data
counts_paper_AC <- data.frame(data_paper %>% select((meta_data %>% filter(experimental_class_type %in% c('A', 'C'), `Assay Type` == 'RNA-Seq'))$Run), row.names = data_paper$Geneid)
counts_paper_AE <- data.frame(data_paper %>% select((meta_data %>% filter(experimental_class_type %in% c('A', 'E'), `Assay Type` == 'RNA-Seq'))$Run), row.names = data_paper$Geneid)

counts_project_AC <- data.frame(data_project %>% select((meta_data %>% filter(experimental_class_type %in% c('A', 'C'), `Assay Type` == 'RNA-Seq'))$Run), row.names = data_project$Geneid)
counts_project_AE <- data.frame(data_project %>% select((meta_data %>% filter(experimental_class_type %in% c('A', 'E'), `Assay Type` == 'RNA-Seq'))$Run), row.names = data_project$Geneid)


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

analysis_template <- file.path(scripts_dir, 'analysis_report.Rmd')
comparison_template <- file.path(scripts_dir, 'comparison_report.Rmd')
summary_template <- file.path(scripts_dir, 'summary_report.Rmd')


# Paper data
rmarkdown::render(
  input = analysis_template,
  output_file = snakemake@output[[1]],
  params = c(
    params_default,
    col_data = list(col_data),
    counts_data = list(counts_paper_AC),
    condition = 'A',
    control = 'C',
    lfc_cutoff = 1
  )
)

rmarkdown::render(
  input = analysis_template,
  output_file = snakemake@output[[2]],
  params = c(
    params_default,
    col_data = list(col_data),
    counts_data = list(counts_paper_AE),
    condition = 'A',
    control = 'E',
    lfc_cutoff = 1
  )
)


# Project data
rmarkdown::render(
  input = analysis_template,
  output_file = snakemake@output[[3]],
  params = c(
    params_default,
    col_data = list(col_data),
    counts_data = list(counts_project_AC),
    condition = 'A',
    control = 'C',
    lfc_cutoff = 1
  )
)

rmarkdown::render(
  input = analysis_template,
  output_file = snakemake@output[[4]],
  params = c(
    params_default,
    col_data = list(col_data),
    counts_data = list(counts_project_AE),
    condition = 'A',
    control = 'E',
    lfc_cutoff = 1
  )
)


# Comparison
rmarkdown::render(
  input = comparison_template,
  output_file = snakemake@output[[5]],
  params = c(
    col_data = list(col_data),
    counts_paper = list(counts_paper_AC),
    counts_project = list(counts_project_AC),
    condition = 'A',
    control = 'C',
    lfc_cutoff = 1
  )
)

rmarkdown::render(
  input = comparison_template,
  output_file = snakemake@output[[6]],
  params = c(
    col_data = list(col_data),
    counts_paper = list(counts_paper_AE),
    counts_project = list(counts_project_AE),
    condition = 'A',
    control = 'E',
    lfc_cutoff = 1
  )
)


# Summary
rmarkdown::render(
  input = summary_template,
  output_file = snakemake@output[[7]],
  params = c(
    meta_data = list(meta_data %>% select(-treatment) %>% dplyr::rename('treatment' = 'experimental_class_type')),
    dir_name = snakemake@params[['outputs_dir']],
    counts_log = snakemake@input[['counts_log']]
  )
)
