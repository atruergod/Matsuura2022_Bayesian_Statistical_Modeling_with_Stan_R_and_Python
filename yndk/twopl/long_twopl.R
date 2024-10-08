# https://mc-stan.org/users/documentation/case-studies/tutorial_twopl.html

library(cmdstanr)
library(posterior)
library(bayesplot)
color_scheme_set("brightblue")

library(data.table)
library(ggplot2)
# check your working directory!!
getwd()



### prepare data
inputfilename <- "./long_scores245_rc.csv" 
dir_path <- dirname(inputfilename)
filename <- basename(inputfilename)

# read data, long format
long = read.csv(inputfilename)

n_items = length(unique(long$item.id))
n_persons = length(unique(long$person.id))
n_data = nrow(long)

if (n_items != max(long$item.id)) {
  print(sprintf("n_items: %d, max item.id: %d", n_items, max(long$item.id)))
}

iid_imsi = seq(1, n_items)
iid_org = unique(long$item.id)

item_index = data.frame()

data_stan = list(I=max(long$item.id), 
                 J=max(long$person.id), 
                 N=nrow(long), 
                 ii=long$item.id,  # index of item/problem/question
                 jj=long$person.id,           # person ability index
                 y=long$response)

### Compile the model

stan_filename = "twopl.stan"
model = cmdstan_model(stan_file = stan_filename)
model$print()
model$exe_file()

# fit with stanr / MCMC

fit <- model$sample(data = data_stan,
                    iter_sampling = 5000,
                    seed=123,
                    chains=4,
                    parallel_chains = 4,
                    refresh = 1000)

## Posterior Summary Statistics
fit$summary()

outdir_name = "outputs"
dir.create("outputs")

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
    geom_text(aes(label = label), vjust = -.81, hjust=-.1) +
    scale_color_manual(values = random_colors) 
    # xlim(-3.5, 3) +
    # ylim(0.4, 1.8)

beta_alpha_fig_file = sprintf("%s/filename_beta_alpha.pdf", outdir_name)
ggsave(beta_alpha_fig_file, plot=g)

## Plot a-b scatter/density

draws_df <- fit$draws(format = "df")
str(draws_df)

mcmc_hist(fit$draws("alpha[1]")) + ggplot2::labs(subtitle = "posterior a[1]") 

mcmc_hist(fit$draws("theta[2]")) +
  ggplot2::labs(subtitle = "Posterior of theta[1]") 


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
      geom_point() + 
      geom_rug(col="darkblue") + 
      stat_density2d() + 
      xlab(b) +
      ylab(a) +
      ggtitle(title_str) + 
      annotate("point", x=bmedian[i], y=amedian[i], color="red", size=2)
  p
  filename = sprintf("%s/posterior-a%d-b%d.pdf", outdir_name, i, i)
  ggsave(filename=filename, plot=p)
}
