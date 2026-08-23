
# Load libraries ---------------------------------------------------

library(mice)
library(MASS)
library(tidyverse)
library(devtools)
library(gdata)
library(VIM)
library(nlmixr2)
source_url('https://raw.githubusercontent.com/R-miss-tastic/website/master/static/how-to/generate/amputation.R')

# Load data ---------------------------------------------------

warfarin_pk <- read.csv("warfarin_pk.csv")

warfarin_pk_baseline <- warfarin_pk |> filter(TIME == 0)

# Fitting the model ---------------------------------------------------

complete.model.war.1cpt.ode <- function(){
  ini({
    tka <- log(1.22)
    tcl <- log(0.136)
    tv <- log(8.24)
    wteff_cl <- 0.597
    wteff_v <- 0.902
    eta.ka ~ 0.731
    eta.cl ~ 0.0717
    eta.v ~ 0.0185
    prop.err <- 0.00535
    add.err <- 0.0843
  })
  model({
    ka <- exp(tka + eta.ka)
    cl <- exp(tcl + wteff_cl * lnWT + eta.cl)
    v <- exp(tv + wteff_v * lnWT + eta.v)
    d/dt(depot) = -ka * depot
    d/dt(cent) = ka * depot - cl/v * cent
    cp = cent/v
    cp ~ prop(prop.err) + add(add.err)
  })
}

## 6.25% WT-i 1, seed 1-30 ---------------------------------------------------

### Identify eligible seeds ---------------------------------------------------

# Initialize variables
nseed <- c(1:30)
seeds_with_sum_2 <- c()
counter <- 1

# Repeat the process
while (length(seeds_with_sum_2) < length(nseed)) {
  # set.seed(counter)
  
  warfarin_miss_6.25_01 <- produce_NA(warfarin_pk_baseline, 
                                    mechanism = "MAR", 
                                    perc.missing = 0.0625,
                                    idx.incomplete = c(0, 0, 0, 0, 0, 0, 1, 0, 0),
                                    idx.covariates = c(0, 0, 0, 0, 0, 0, 0, 1, 1), 
                                    weights.covariates = c(0, 0, 0, 0, 0, 0, 0, 1/2, 1/2),
                                    logit.model = "RIGHT",
                                    seed = counter)
  
  warfarin_incomp_6.25_01 <- warfarin_miss_6.25_01$data.incomp
  
  if (sum(is.na(warfarin_incomp_6.25_01$WT)) == 2) {
    seeds_with_sum_2 <- c(seeds_with_sum_2, counter)
  }
  
  counter <- counter + 1
}

# Save the seeds
seeds_with_sum_2

### Generate missing datasets ------------------------------------------------

warfarin_miss_6.25_01 <- produce_NA(warfarin_pk_baseline, 
                                  mechanism = "MAR", 
                                  perc.missing = 0.0625,
                                  idx.incomplete = c(0, 0, 0, 0, 0, 0, 1, 0, 0),
                                  idx.covariates = c(0, 0, 0, 0, 0, 0, 0, 1, 1), 
                                  weights.covariates = c(0, 0, 0, 0, 0, 0, 0, 1/2, 1/2),
                                  logit.model = "RIGHT",
                                  seed = seeds_with_sum_2[1])

warfarin_incomp_6.25_01 <- warfarin_miss_6.25_01$data.incomp

warfarin_incomp_6.25_01_long <- warfarin_pk

warfarin_incomp_6.25_01_long$WT <- ifelse(warfarin_incomp_6.25_01_long$ID %in% warfarin_incomp_6.25_01$ID, 
                                        warfarin_incomp_6.25_01$WT[match(warfarin_incomp_6.25_01_long$ID, 
                                                                       warfarin_incomp_6.25_01$ID)], 
                                        warfarin_incomp_6.25_01_long$WT)

#### Multiple imputation - 1st seed ----------------------------------------

imp0 <- mice(warfarin_incomp_6.25_01_long, maxit = 0)
meth <- imp0$method
meth["WT"] <- "norm"
predictorMatrix <- imp0$predictorMatrix
# predictorMatrix[,"lnWT"] <- 0
predictorMatrix[,"EVID"] <- 0
maxit <- 20
nimp_6.25 <- 20

missing_wt_ids_6.25_01 <- warfarin_incomp_6.25_01 %>%
  filter(is.na(WT)) %>%
  pull(ID)

for (i in seq_len(30)) {

imputed_data <- mice(data = warfarin_incomp_6.25_01_long,
                     method = meth,
                     predictorMatrix = predictorMatrix,
                     maxit = maxit, 
                     m = nimp_6.25, 
                     printFlag  =  FALSE,
                     seed = nseed[i])

for (j in seq_len(nimp_6.25)) {
  dat_MI01_6.25_01 <- complete(imputed_data, j)
  
  # average WT per ID
  average_wt_MI01_6.25_01 <- dat_MI01_6.25_01 %>%
    filter(ID %in% missing_wt_ids_6.25_01) %>%
    group_by(ID) %>%
    summarize(avg_WT = mean(WT, na.rm = TRUE))
  
  dat_MI01_6.25_01 <- dat_MI01_6.25_01 %>%
    left_join(average_wt_MI01_6.25_01, by = "ID") %>%
    mutate(WT = ifelse(ID %in% missing_wt_ids_6.25_01, avg_WT, WT),
           lnWT = log(WT / 71.7)) %>%
    select(-avg_WT)
  
  assign(paste0("fit.war.mi", sprintf("%02d", j), ".seed", sprintf("%02d", i), ".6.25.", sprintf("%02d", 1)), 
         nlmixr(complete.model.war.1cpt.ode,
                dat_MI01_6.25_01, 
                est = "focei",
                control = list(print = 0))$parFixed)
}
}

##### Extract the required data -------------------------------------

# for MI

combined_data_list_mi_converged <- list()
combined_data_list_mi_unconverged  <- list()

for (i in seq_len(30)) {
for (j in seq_len(nimp_6.25)) {
  dataset_name <- paste0("fit.war.mi", sprintf("%02d", j), ".seed", sprintf("%02d", i), ".6.25.", sprintf("%02d", 1))
  
  if (exists(dataset_name) && !is.null(get(dataset_name))) {
    data <- get(dataset_name)
    
    if ("SE" %in% colnames(data)) {
      extracted_data <- data[4:5, 2:3] %>%
        mutate(imputation = j,
               later_seed = i,
               initial_seed = 1,
               type = "MI",
               converged = "Yes")
      
      combined_data_list_mi_converged[[length(combined_data_list_mi_converged) + 1]] <- extracted_data
      
    } else {
      extracted_data <- data[4:5, 1:2] %>%
        mutate(imputation = j,
               later_seed = i,
               initial_seed = 1,
               type = "MI",
               converged = "No")
      
      combined_data_list_mi_unconverged[[length(combined_data_list_mi_unconverged) + 1]] <- extracted_data
    }
  }
}
}

merged.war.mi.seed01.30.6.25.01.converged <- do.call(rbind, combined_data_list_mi_converged)
merged.war.mi.seed01.30.6.25.01.unconverged <- do.call(rbind, combined_data_list_mi_unconverged)

# Export the data
write.csv(merged.war.mi.seed01.30.6.25.01.converged, 
          "results/merged.war.mi.seed01.30.6.25.01.converged.csv", 
          quote = F, 
          row.names = F)

write.csv(merged.war.mi.seed01.30.6.25.01.unconverged, 
          "results/merged.war.mi.seed01.30.6.25.01.unconverged.csv", 
          quote = F, 
          row.names = F)
