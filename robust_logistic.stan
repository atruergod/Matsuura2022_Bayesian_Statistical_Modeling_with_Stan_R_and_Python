
data {
  int<lower=0> N;                // 데이터 개수 (Train set)
  int<lower=0> K;                // 예측 변수 개수 (4개)
  matrix[N, K] X;                // 예측 변수 행렬 (표준화됨)
  array[N] int<lower=0, 1> y;    // 종속 변수 (0 또는 1)
}

parameters {
  // Eq 5: 이상치 처리를 위한 추측 파라미터 (0~1)
  real<lower=0, upper=1> alpha; 

  // Eq 3, 4: 회귀 계수
  real beta0;                    // 절편
  vector[K] beta;                // 기울기 벡터
}

model {
  // === Priors (사전 분포) ===
  // 논문에 명시된 분포: alpha ~ beta(1, 100)
  alpha ~ beta(1, 100); 

  // 회귀 계수에 대한 Weakly Informative Priors
  beta0 ~ normal(0, 10);
  beta ~ normal(0, 2.5);

  // === Likelihood (우도 함수) ===
  vector[N] linear_pred = beta0 + X * beta;

  for (n in 1:N) {
    // Eq 2: Robust Logistic Function (추측 파라미터 혼합)
    // alpha * 0.5 (무작위 추측) + (1-alpha) * logistic_model
    real prob = alpha * 0.5 + (1 - alpha) * inv_logit(linear_pred[n]);

    // 관측값 y는 해당 확률을 따르는 베르누이 분포
    y[n] ~ bernoulli(prob);
  }
}
