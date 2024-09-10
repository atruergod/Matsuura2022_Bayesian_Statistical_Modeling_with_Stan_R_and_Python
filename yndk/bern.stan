// Bernoulli model
// https://avehtari.github.io/BDA_R_demos/demos_rstan/rstan_demo.html
data {
  int<lower=0> N; // number of observations
  array[N] int<lower=0, upper=1> Y; // vector of binary observations
}
parameters {
  real<lower=0, upper=1> theta; // probability of success
}
model {
  // model block creates the log density to be sampled
  theta ~ beta(1, 1); // prior
  Y ~ bernoulli(theta); // observation model / likelihood
  // the notation using ~ is syntactic sugar for
  //  target += beta_lpdf(theta | 1, 1);   // lpdf for continuous theta
  // target += bernoulli_lpmf(y | theta); // lpmf for discrete y
  // target is the log density to be sampled
  //
  // y is an array of integers and
  //  y ~ bernoulli(theta);
  // is equivalent to
  //  for (i in 1:N) {
  //    y[i] ~ bernoulli(theta);
  //  }
  // which is equivalent to
  //  for (i in 1:N) {
  //    target += bernoulli_lpmf(y[i] | theta);
  //  }
}

