
data {
  int<lower=0> N;
  int<lower=0> K;
  matrix[N, K] X;
  array[N] int<lower=0, upper=1> y;
}
parameters {
  real beta0;
  vector[K] betas;
  // 여기엔 alpha(찍기 확률)가 없습니다! 훨씬 단순하죠?
}
model {
  // 사전 분포 설정 (Ridge Regression 효과를 주어 과적합 방지)
  beta0 ~ normal(0, 2);
  betas ~ normal(0, 1); 

  // 표준 로지스틱 회귀 식
  y ~ bernoulli_logit(beta0 + X * betas);
}
