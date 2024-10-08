# https://mc-stan.org/users/documentation/case-studies/tutorial_twopl.html

# Try 3. Direct use of Stan without edstan package

library(data.table)
library(ggplot2)
# check your working directory!!
getwd()


### We use CmdStanR : Install and load libraries

# install.packages("cmdstanr", 
#                  repos = c('https://stan-dev.r-universe.dev', 
#                            getOption("repos"))
#                  )

library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

# check_cmdstan_toolchain()
# install_cmdstan(cores = 4)

cmdstan_path()

### Compile the model

stan_filename = "twopl.stan"
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

mcmc_hist(fit$draws("alpha[1]")) + ggplot2::labs(subtitle = "posterior a[1]") 

mcmc_hist(fit$draws("theta[2]")) +
  ggplot2::labs(subtitle = "Posterior of theta[1]") 

class(draws_arr)


### file output

outdir_name <- "outputs"
dir.create(outdir_name, showWarnings = FALSE)

### median of a
amedian <- rep(0, 25) # array for 
for (i in 1:25){
  ss = sprintf("alpha[%d]", i)
  samples = fit$draws(ss)
  m = min(samples)
  M = max(samples)
  med = median(samples)
  amedian[i] = med
  me  = mean(samples)
  print(paste(i, m, med, M))

  png(filename=sprintf("%s/%s.png", outdir_name, ss))
  hist(fit$draws(ss), 
       # xlim = range(c(0, 5)),
       main=paste(ss, "m:", m, "med: ", med, "M:", M), 
       breaks="FD", 
       probability = TRUE)
  abline(v = med, col="#F00000")
  abline(v = me,  col="#0000F0")
  dev.off()
}  

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

abmedian = data.frame(amedian, bmedian)
# Convert row names to a column
abmedian$label = rownames(abmedian)
# Generate a set of random colors
set.seed(123)  # For reproducibility
random_colors <- sample(colors(), nrow(abmedian))
# Create ggplot with random colors
g <- ggplot(abmedian, aes(x = bmedian , y = amedian)) +
    geom_point(aes(color = label), size = 3) +
    geom_text(aes(label = label), vjust = -1, hjust=-.1) +
    scale_color_manual(values = random_colors)

beta_alpha_plot = sprintf("%s/beta-alpha.pdf", outdir_name)
ggsave(beta_alpha_plot, plot=g)
g

## alpha-beta scatter plot

i = 1

ggplot(draws_df, aes(x=`beta[1]`, y=`alpha[1]`)) + 
      geom_point(col='darkblue', alpha=.3) + 
      geom_rug(col='darkblue') + 
      stat_density2d(col='darkred')

ggsave(filename, plot = p)


draws_df <- fit$draws(format = "df")
str(draws_df)

mcmc_hist(fit$draws("alpha[1]")) + ggplot2::labs(subtitle = "posterior a[1]") 

mcmc_hist(fit$draws("theta[2]")) + ggplot2::labs(subtitle = "Posterior of theta[1]") 


for (k in 1:length(amedian)) {
  i = k
  # i = 2
  a = sprintf("alpha[%d]", i)
  b = sprintf("beta[%d]", i)
  # below fit$draws(a) returns a [5000, 4, 1] array
  # convert to a vector of 20000 by c()
  d2 = data.frame( y = c(fit$draws(a)), x = c(fit$draws(b)))
  title_str = sprintf("Posterior(b%d,a%d) median=(b= %.2f, a= %.2f)", 
                      i, i, bmedian[i], amedian[i])
  p <- ggplot(d2, aes(x=x, y=y)) + 
    geom_point(alpha=.1) + 
    geom_rug(col="darkblue") + 
    stat_density2d(bins=10) + 
    xlab(b) +
    ylab(a) +
    ggtitle(title_str) + 
    annotate("point", x=bmedian[i], y=amedian[i], color="red", size=2)
  p
  filename = sprintf("%s/posterior-a%d-b%d.pdf", outdir_name, i, i)
  ggsave(filename=filename, plot=p)
}
