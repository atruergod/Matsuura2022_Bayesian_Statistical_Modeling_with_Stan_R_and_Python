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
    #### male, infidelity, panoramic, succumb, girder; 
    #### omit mail
    X = spelling[,2:6]  
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

mcmc_hist(fit$draws("alpha[1]")) 

mcmc_hist(fit$draws("theta[1]")) +
  ggplot2::labs(subtitle = "Posterior of theta[1]") 

class(draws_arr)

