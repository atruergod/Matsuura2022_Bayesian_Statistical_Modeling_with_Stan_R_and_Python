
data {
  int<lower=1> N;   // 학생 수
  int<lower=1> J;   // 문항 수
  array[N, J] int<lower=0, upper=1> y;  // 응답 행렬 (N x J)
  vector[J] difficulty; // 이미 알고 있는 문항 난이도
}

parameters {
  vector[N] ability;    // 추정해야 할 학생의 능력
}

model {
  // Prior: [-2, 2] 범위를 충분히 커버하도록 설정
  ability ~ normal(0, 3);

  // Likelihood
  for (j in 1:J) {
    for (n in 1:N) {
      y[n,j] ~ bernoulli_logit(ability[n] - difficulty[j]);
    }
  }
}
