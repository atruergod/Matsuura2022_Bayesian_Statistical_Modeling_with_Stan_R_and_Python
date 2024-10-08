# simulation
# to see the posterior spread depending on
# 1. the number of testees
# 2. the number of items

library(dplyr)
library(data.table)
library(ggplot2)
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

cmdstan_path()
# check your working directory!!
getwd()


### simulation data generation

Nstudents = 5000
ability_true = rnorm(Nstudents, 0, 1)
hist(ability_true)

Nitems = 300
difficulty_true = rnorm(Nitems, 0, 1)
difficulty_true = runif(Nitems, -2, 2)
print(difficulty_true)
plot(difficulty_true)

#### Now take exam
dfscore = data.frame(st_id=1:Nstudents)

for (item in 1:Nitems) {
  d = difficulty_true[item]
  # prob of all the students
  prob = 1. / (1 + exp(-(ability_true - d)))
  score = rbinom(Nstudents, 1, prob = prob)  # take the examination
  iname = sprintf("item_%d", item)
  dfscore[iname] <- score
}

# except for the first column st_id

df <- dfscore %>% select(-st_id) 

item_names <- names(df)
df$person.id <- 1:nrow(df)

### Now make a long form from a wide from

long <- pivot_longer(df, cols=item_names, 
                     names_to = "item", 
                     values_to = "response")
key <- 1:length(unique(long$item))
names(key) <- unique(long$item)
long$item.id <- key[long$item]

### prepare data for stan

data_stan = list(I=max(long$item.id), 
                 J=max(long$person.id), 
                 N=nrow(long), 
                 ii=long$item.id,  # index of item/problem/question
                 jj=long$person.id,           # person ability index
                 y=long$response)


### fit with stanr / MCMC

# Compile the model

stan_filename = "rasch.stan"
model = cmdstan_model(stan_file = stan_filename)
model$print()
model$exe_file()


fit <- model$sample(data = data_stan,
                    iter_sampling = 2500,
                    seed=123,
                    chains=4,
                    parallel_chains = 4,
                    refresh = 1000)

## Posterior Summary Statistics
summ <- fit$summary()
summ


par_bkp <- par(no.readonly = TRUE)
par(mfrow=c(1,3))
hist(fit$draws("delta[1]"))
hist(fit$draws("delta[2]"))
hist(fit$draws("delta[3]"))
par(par_bkp)

hist(fit$draws("theta[1]"))







draws_arr = fit$draws()
str(draws_arr)

draws_df <- fit$draws(format = "df")
str(draws_df)

print(identical(draws_df, as_draws_df(draws_arr)))

mcmc_hist(fit$draws("delta[1]")) + ggplot2::labs(subtitle = "posterior a[1]") 

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

