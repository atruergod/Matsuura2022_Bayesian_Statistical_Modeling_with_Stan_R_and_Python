
data {
  int<lower=1> N;   // number of students
  int<lower=1> J;   // number of items
  array[N, J] int<lower=0, upper=1> y;  // response (0 or 1)
  vector[J] difficulty;
}
parameters {
  vector[N] ability;    // ability of each student
}
model {
  // prior for ability
  ability ~ normal(0, 5);

  // likelihood
for (j in 1:J) {
  for (n in 1:N) {
y[n,j] ~ bernoulli_logit
