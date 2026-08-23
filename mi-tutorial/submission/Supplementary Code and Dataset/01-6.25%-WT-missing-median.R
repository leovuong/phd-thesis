
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

## 6.25% missing WT ---------------------------------------------------

### Identify eligible seeds ---------------------------------------------------

# Initialize variables
nseed <- 30
seeds_with_sum_2 <- c()
counter <- 1

# Repeat the process
while (length(seeds_with_sum_2) < nseed) {
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

for (i in seq_along(seeds_with_sum_2)) {
  warfarin_miss_6.25_01 <- produce_NA(warfarin_pk_baseline, 
                                    mechanism = "MAR", 
                                    perc.missing = 0.0625,
                                    idx.incomplete = c(0, 0, 0, 0, 0, 0, 1, 0, 0),
                                    idx.covariates = c(0, 0, 0, 0, 0, 0, 0, 1, 1), 
                                    weights.covariates = c(0, 0, 0, 0, 0, 0, 0, 1/2, 1/2),
                                    logit.model = "RIGHT",
                                    seed = seeds_with_sum_2[i])
  
  warfarin_incomp_6.25_01 <- warfarin_miss_6.25_01$data.incomp
  
  #### Median imputation ---------------------------------------------------
  
  median_WT_6.25_01 <- median(warfarin_incomp_6.25_01$WT, na.rm = TRUE)
  
  warfarin_incomp_6.25_01_long <- warfarin_pk
  
  warfarin_incomp_6.25_01_long$WT <- ifelse(warfarin_incomp_6.25_01_long$ID %in% warfarin_incomp_6.25_01$ID, 
                                          warfarin_incomp_6.25_01$WT[match(warfarin_incomp_6.25_01_long$ID, 
                                                                         warfarin_incomp_6.25_01$ID)], 
                                          warfarin_incomp_6.25_01_long$WT)
  
  warfarin_median_6.25_01 <- warfarin_incomp_6.25_01_long |> 
    mutate(WT = ifelse(is.na(WT), median_WT_6.25_01, WT))
  
  # Fit the model with the median imputed dataset
  warfarin_median_6.25_01$lnWT <- log(warfarin_median_6.25_01$WT/71.7)
  
  # Run the model and store the results
  assign(paste0("fit.war.median.6.25.", sprintf("%02d", i)), 
         nlmixr(complete.model.war.1cpt.ode,
                warfarin_median_6.25_01, 
                est = "focei",
                control = list(print = 0))$parFixed)
}

##### Extract the required data -------------------------------------

combined_data_list_median_converged <- list()
combined_data_list_median_unconverged <- list()

for (i in seq_along(seeds_with_sum_2)) {
  dataset_name <- paste0("fit.war.median.6.25.", sprintf("%02d", i))
  
  if (exists(dataset_name) && !is.null(get(dataset_name))) {
    data <- get(dataset_name)
    
    if ("SE" %in% colnames(data)) {
      extracted_data <- data[4:5, 2:3] %>%
        mutate(imputation = NA,
               later_seed = NA,
               initial_seed = i,
               type = "Median",
               converged = "Yes")
      
      combined_data_list_median_converged[[length(combined_data_list_median_converged) + 1]] <- extracted_data
    } else {
      extracted_data <- data[4:5, 1:2] %>%
        mutate(imputation = NA,
               later_seed = NA,
               initial_seed = i,
               type = "Median",
               converged = "No")
      
      combined_data_list_median_unconverged[[length(combined_data_list_median_unconverged) + 1]] <- extracted_data
    }
  }
}

merged.war.median.6.25.converged <- do.call(rbind, combined_data_list_median_converged)
merged.war.median.6.25.unconverged <- do.call(rbind, combined_data_list_median_unconverged)

# Export the data
write.csv(merged.war.median.6.25.converged, 
          "results/merged.war.median.6.25.converged.csv", 
          quote = F, 
          row.names = F)

write.csv(merged.war.median.6.25.unconverged, 
          "results/merged.war.median.6.25.unconverged.csv", 
          quote = F, 
          row.names = F)
