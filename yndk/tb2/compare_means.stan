
data {
    int<lower=0> N1;         // number of treated samples
    int<lower=0> N2;         // number of control samples
    vector[N1] y1;           // treated responses
    vector[N2] y2;           // control responses
}
parameters {
    real mu1;                // mean of treated
    real mu2;                // mean of control
    real<lower=0> sigma1;    // std dev of treated
    real<lower=0> sigma2;    // std dev of control
}
model {
    mu1 ~ normal(0, 100);
    mu2 ~ normal(0, 100);
    sigma1 ~ exponential(.1);
    sigma2 ~ exponential(.1);
    y1 ~ normal(mu1, sigma1);
    y2 ~ normal(mu2, sigma2);
}
generated quantities {
    real diff_means = mu1 - mu2;
}
