# https://mc-stan.org/users/documentation/case-studies/tutorial_twopl.html

# Try 3. Direct use of Stan without edstan package

library(data.table)
library(ggplot2)
# check your working directory!!
getwd()

# install rstan
# https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
install.packages("rstan", repos = c('https://stan-dev.r-universe.dev', getOption("repos")))

library(rstan)
rstan_options(auto_write = TRUE)
rstan_options(threads_per_chain = 1)
options(mc.cores = parallel::detectCores()).

stan_filename = "twopl.stan"

# prepare data
spelling = read.csv("spelling.csv")

preview_rows <- seq(from = 1, to = nrow(spelling), length.out = 10)
print(spelling[preview_rows, ])

## summary of the data
### Record existing plot presets and prepare to make side-by-side pots
    par_bkp <- par(no.readonly = TRUE)
    par(mfrow = c(1, 2))
    
    # Left plot
    person_scores <- apply(spelling[, 2:5], 1, sum)
    person_counts <- table(person_scores)
    barplot(person_counts, main = "Raw score distribution", xlab = "Raw score", 
            ylab = "Number of persons")
    
    # Right plot
    item_scores <- apply(spelling[, 2:5], 2, mean)
    barplot(item_scores, main = "Proportion correct by item", ylab = "Proportion correct", 
            ylim = c(0, 1), xaxt = "n")
    # x-axis with angled labels
    text(x = 0.85 + (1:length(item_scores) - 1) * 1.2, y = -0.05, labels = names(item_scores), 
         xpd = TRUE, srt = 30, pos = 2)
    
    # Return to previous plot presets
    par(par_bkp)
### 

### wide -> long
    X = spelling[,2:6]  # male, infidelity, panoramic, succumb, girder
    wide <- as.data.frame(X)
    wide$person.id <- 1:nrow(wide)
    long <- melt(wide,   # library(data.table)
                 id.vars=c("person.id", "male"), 
                 measure.vars=names(wide)[2:5], 
                 variable.name = "item",
                 value.name="response")
    
    key <- 1:length(unique(long$item))
    names(key) <- unique(long$item)
    long$item.id <- key[long$item]
    
    data_stan = list(I=max(long$item.id), 
                    J=max(long$person.id), 
                    N=nrow(long), 
                    ii=long$item.id,  # index of item/problem/question
                    jj=long$person.id,           # person ability index
                    y=long$response)


# fit with MCMC
    
twopl.fit <- stan(file = stan_filename, 
                  model_name = "twopl",
                  data = data_stan,
                  iter = 2000,
                  chains = 4)

print(twopl.fit, pars=c("alpha", "beta"))

## posterior of a parameter
  stan_hist(twopl.fit, pars=c("alpha[1]", "alpha[2]", "alpha[3]", "alpha[4]")) + geom_vline(xintercept=0)
  
  stan_hist(twopl.fit, pars=c("beta[1]", "beta[2]", "beta[3]", "beta[4]"))
##
