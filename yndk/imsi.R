# Load packages
library(rstan)
rstan_options(threads_per_chain = 1)
rstan_options(auto_write = TRUE)

# Install edstan development version of edstan
# install.packages("devtools")
library(devtools)
devtools::install_github("danielcfurr/edstan")

library(edstan)

# Make the data list
data_dich <- irt_data(y = aggression$dich, 
                      ii = labelled_integer(aggression$description), 
                      jj = aggression$person)

# Fit the Rasch model
fit_rasch <- irt_stan(data_dich, model = "rasch_latent_reg.stan",
                      iter = 200, chains = 4)

# View convergence statistics
rhat_columns(fit_rasch)

# View summary of parameter posteriors					  
print_irt_stan(fit_rasch, data_dich)

# Add a latent regression to the previous model
data_lr <- irt_data(y = aggression$dich, 
                    ii = labelled_integer(aggression$description), 
                    jj = aggression$person,
                    covariates = aggression[, c("male", "anger")],
                    formula = ~ 1 + male*aggression)
fit_lr <- irt_stan(data_lr, model = "rasch_latent_reg.stan",
                   iter = 200, chains = 4)