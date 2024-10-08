# https://mc-stan.org/users/documentation/case-studies/tutorial_twopl.html

# Try 3. Direct use of Stan without edstan package

library(data.table)
library(ggplot2)
# check your working directory!!
getwd()

library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

cmdstan_path()

### Compile the model

stan_filename = "rasch.stan"
model = cmdstan_model(stan_file = stan_filename)
model$print()
model$exe_file()


### prepare data
    long = read.csv("scores_long.csv")
    

    data_stan = list(I=max(long$item.id), 
                     J=max(long$person.id), 
                     N=nrow(long), 
                     ii=long$item.id,  # index of item/problem/question
                     jj=long$person.id,           # person ability index
                     y=long$response)
    

# fit with stanr / MCMC

fit <- model$sample(data = data_stan,
                    iter_sampling = 5000,
                    seed=123,
                    chains=4,
                    parallel_chains = 4,
                    refresh = 1000)

## Posterior Summary Statistics
fit$summary()

draws_arr = fit$draws()
str(draws_arr)

draws_df <- fit$draws(format = "df")
str(draws_df)

print(identical(draws_df, as_draws_df(draws_arr)))

mcmc_hist(fit$draws("beta[1]")) + ggplot2::labs(subtitle = "posterior a[1]") 

mcmc_hist(fit$draws("theta[2]")) +
  ggplot2::labs(subtitle = "Posterior of theta[1]") 

class(draws_arr)


### file output

outdir_name <- "outputs"
dir.create(outdir_name, showWarnings = FALSE)


bmedian <- rep(0, 25)
for (i in 1:25){
  ss = sprintf("beta[%d]", i)
  m = median(fit$draws(ss))
  bmedian[i] = m
  print(paste(ss, m))
}

theta_median <- rep(0, 25)
for (i in 1:61){
  ss = sprintf("theta[%d]", i)
  m = median(fit$draws(ss))
  theta_median[i] = m
  print(paste(ss, m))
}  


draws_df <- fit$draws(format = "df")
str(draws_df)

mcmc_hist(fit$draws("beta[1]")) + 
  ggplot2::labs(subtitle = "posterior beta[1]") 

mcmc_hist(fit$draws("theta[2]")) + ggplot2::labs(subtitle = "Posterior of theta[1]") 

