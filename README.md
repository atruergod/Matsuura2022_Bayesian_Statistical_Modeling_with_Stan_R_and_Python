# Bayesian Statistical Modeling with Stan, R, and Python
- Kentaro Matsuura (2023). Bayesian Statistical Modeling with Stan, R, and Python. Singapore: Springer.
- URL: https://link.springer.com/book/10.1007/978-981-19-4755-1
- URL: https://www.amazon.com/dp/9811947546/

## Eratta
[here](errata.md)

## Tested Environment
| Software/Package Name | Version (publication) | Version (now) |
|:-----------|:------------|:------------|
| OS | Windows 11 (64bit) | Windows 11 (64bit) |
| Stan | 2.29.2 | 2.31.0 |
| R | 4.1.3 | 4.2.2 |
| cmdstanr | 0.5.0 | 0.5.3 |
| Python | 3.10.6 | 3.11.0 |
| cmdstanpy | 1.0.1 | 1.1.0 |


## Install cmdstanr

### 1. R & Rstudio
### Uninstall if Your `R` install path contains a space. 
1. Run .libPaths() and save the two directories shown on the console
2. Uninstall R and RStudio from Windows "Programs and Features" menu.
3. Delete everything in folders that was shown after running .libPaths() in R.
4. Delete everything in c:\Users\%USERNAME%\AppData\Local\RStudio-Desktop\

### Install R & Rstudio
1. goto https://cran.rstudio.com/, download R-4.4.1 for Windows (https://cran.rstudio.com/bin/windows/base/R-4.4.1-win.exe)
    - Run the file    
    - set path to `C:\R\R-4.4.1`
2. Rtools: https://cran.rstudio.com/bin/windows/Rtools/rtools44/files/rtools44-6104-6039.exe
    -  installation path is `C:\rtools44`
3. Rstudio: https://download1.rstudio.org/electron/windows/RStudio-2024.04.2-764.exe 
    - `C:\RStudio`

4. Edit `C:\R\R-4.4.1\etc\Rconsole` to have original English message.
     ```
       language = en
     ```
  
### cmdstanr

Follow the command in:
https://blog.mc-stan.org/2022/04/26/stan-r-4-2-on-windows/#:~:text=Check%20the%20toolchain%20and%20install%20CmdStan%20cmdstanr%3A%3Acheck_cmdstan_toolchain%28fix%20%3D,version%20of%20CmdStan%20install%20%23%20cmdstanr%3A%3Ainstall_cmdstan%28overwrite%20%3D%20TRUE%29 

The first two are:
```
  > install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
  > cmdstanr::check_cmdstan_toolchain(fix = TRUE)
```
If you come to see an error message, then you must fix it first.

## Learning R
- Hands-On Programming with R: https://rstudio-education.github.io/hopr/basics.html 
- Working directory is important at the starting point.
      ```
          > getwd()
      ```
  - Default working directory : `Tools -> Global Options`
  - `Session -> Set Working Directory -> Choose Directory` or `Ctrl+Shift+H`
## Plotting with `ggplot2` or `tidyverse`
- R Graphics Cookbook 2e: https://r-graphics.org/ 
- R for Data Science 2e: https://r4ds.hadley.nz/data-visualize
- 
