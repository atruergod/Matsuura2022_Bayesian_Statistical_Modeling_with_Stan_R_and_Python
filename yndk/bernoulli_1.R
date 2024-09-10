library(cmdstanr)

Y = c(1,1,1, 0, 1,1,1, 0, 1, 0)
N = length(Y)

d <- data.frame(Y=Y)
data <- list(N=nrow(d), Y=d$Y)
model <- cmdstan_model(stan_file='bern.stan')
fit <- model$sample(data=data, seed=123)

theta_samples = fit$draws('theta')

fit$save_object(file='bernoulli_1.RDS')
write.table(fit$summary(), file='bernoulli_1_summary.csv',
            sep=',', quote=TRUE, row.names=FALSE)

library(coda)
pdf(file='bernoulli_1_fit_plot.pdf')
plot(as_mcmc.list(fit))
dev.off()


# # with another prior distribution
model55 <- cmdstan_model(stan_file = 'bern_a5_b5.stan')
fit55 <- model55$sample(data=data, seed=1235)
thetas55 = fit55$draws('theta')
