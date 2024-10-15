#
#
library(ggplot2)
library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")


# 0. Simulation data generation

set.seed(123)
N1 <- 30
N2 <- 20
mean1 <- 0
mean2 <- 1
sd1 <- 5
sd2 <- 4
Y1 <- rnorm(n=N1, mean=mean1, sd=sd1)
Y2 <- rnorm(n=N2, mean=mean2, sd=sd2)

df <- data.frame(Y = c(Y1, Y2), group = c(rep(1, N1), rep(2, N2)))

#
# 1. Visualize the data from these two groups so that we can intuitively see whether 
#    the difference exists between them.


# The group column now contains numbers 1 and 2.
# The fill = factor(group) ensures the numeric groups are treated as categorical variables for coloring.

ggplot(df, aes(x=Y, fill=factor(group))) + 
  geom_histogram(position = "identity", alpha=.5)



#
# (2) Write a model formula with the assumption that these two groups have the same 
#     SD. This corresponds to the Students’ t-test

stan_program_2 <- "
data {
  int<lower=0> N;
  vector[N] Y;
  array[N] int<lower=1,upper=2> group;
}

parameters {
  vector[2] mean;
  real<lower=0> sigma;
}

model {
  for (i in 1:N) {
    Y[i] ~ normal(mean[group[i]], sigma);
  }
}

generated quantities {
  real effect = mean[2] - mean[1];  // how much positive effect
}
"
stan_file <- write_stan_file(stan_program_2, dir = "./stan", force_overwrite = TRUE)

model2 <- cmdstan_model(stan_file)


data_list2 <- list(N = nrow(df), Y = df$Y, group = df$group)

fit2 <- model2$sample(data = data_list2, seed=123, chains = 4, parallel_chains = 4)

fit2$summary()

mcmc_hist(fit2$draws())

mcmc_pairs(fit2$draws(c("mean", "sigma", "effect")))

m1s <- c(fit2$draws("mean[1]"))  # make a long vector using c()
m2s <- c(fit2$draws("mean[2]"))  # make a long vector using c()

Pr_1lt2 = sum(m1s < m2s) / length(m1s)
print(sprintf("Pr[mu1 < mu2]  = %.2f", Pr_1lt2))
positive_effect = fit2$draws("effect")>0
print(sprintf("Pr[effect > 0] = %.2f", mean(positive_effect)))

ggplot(data.frame(m1 = m1s, m2=m2s), aes(x=m2, y=m1)) + 
  geom_point(alpha=.35, color = "#0fa0ef") + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  ggtitle(sprintf("Pr[mu1 < mu2] = %.2f   Common sigma model", Pr_1lt2))

ggplot(data.frame(effect = c(fit2$draws("effect"))), aes(x=effect)) +
  geom_histogram(bins = 50, color = "#0fa0ef") +
  geom_vline(xintercept = 0, color="darkred")

#
# (5) Write a model formula with the assumption that the two SDs are different. This 
#     is equivalent to the Welch’s t-test. Similarly, compute Prob[μ1 < μ2]. 

stan_program_5 <- "
data {
  int<lower=0> N;
  vector[N] Y;
  array[N] int<lower=1,upper=2> group;
}

parameters {
  vector[2] mean;
  array[2] real<lower=0> sigma;
}

model {
//  for (i in 1:N) {
//    Y[i] ~ normal(mean[group[i]], sigma[group[i]]);
//  }
    Y[1:N] ~ normal(mean[group[1:N]], sigma[group[1:N]]);  // vector form
}

generated quantities {
  real effect = mean[2] - mean[1];  // how much positive effect
}
"
stan_file5 <- write_stan_file(stan_program_5, 
                              dir = "./stan", force_overwrite = TRUE)

model5 <- cmdstan_model(stan_file5)

data_list5 <- list(N = nrow(df), Y = df$Y, group = df$group)

fit5 <- model5$sample(data = data_list5, 
                      seed=123, chains = 4, parallel_chains = 4)

fit5$summary()

mcmc_hist(fit5$draws())

mcmc_pairs(fit5$draws(c("mean", "sigma")))

m1s <- c(fit5$draws("mean[1]"))  # make a long vector using c()
m2s <- c(fit5$draws("mean[2]"))  # make a long vector using c()

Pr_1lt2 = sum(m1s < m2s) / length(m1s)
print(sprintf("Pr[mu1 < mu2] = %.2f", Pr_1lt2))

ggplot(data.frame(m1 = m1s, m2=m2s), aes(x=m2, y=m1)) + 
  geom_point(alpha=.35, color = "#0fa0ef") + 
  geom_abline(slope = 1, intercept = 0, color = "red") +
  ggtitle(sprintf("Pr[m1 < m2] = %.2f; Welch’s t-test (separate sigma model)", Pr_1lt2))

