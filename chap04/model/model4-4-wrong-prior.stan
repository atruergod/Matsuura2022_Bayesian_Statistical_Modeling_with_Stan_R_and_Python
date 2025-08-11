data {
  int N;
  vector[N] X;
  vector[N] Y;
}

parameters {
  real a;
  real b;
  real<lower=0> sigma;
}

model {
  Y[1:N] ~ normal(a + b*X[1:N], sigma);

    // Prior distributions
    a ~ normal(0, 1);  // mean of a is around 40 actually
    b ~ normal(0, 1); 
    sigma ~ exponential(1);
}
// we are going to use this model with a wrong prior
// for the sake of demonstration, we will use a prior that is not suitable for the data
