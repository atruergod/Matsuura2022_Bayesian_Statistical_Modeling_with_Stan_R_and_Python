
data {
  int<lower=0> N;                // 데이터 개수 (학생 수, 666명)
  int<lower=0> K;                // 과목 수 (4과목)
  matrix[N, K] X;                // 학생들의 성적 데이터 (입력값)
  array[N] int<lower=0, upper=1> y;    // 합격 여부 (0 또는 1, 결과값)
}

parameters {
  real beta0;                    // 기본 합격 점수 (절편)
  vector[K] betas;               // 각 과목이 합격에 미치는 영향력 (회귀 계수)
  real<lower=0, upper=1> alpha;  // 중요! '찍어서 맞힐 확률' (0~1 사이 값)
}

model {
  // 1. 사전 분포(Priors): 분석하기 전, 파라미터에 대한 우리의 믿음
  alpha ~ beta(1, 100);          // alpha는 아주 작은 값일 것이라고 가정함
  beta0 ~ normal(0, 10);         // beta0는 0 근처일 것임 (표준편차 10)
  betas ~ normal(0, 10);         // 각 과목 영향력도 0 근처일 것임

  // 2. 모델 식 계산
  vector[N] mu;
  mu = beta0 + X * betas;        // 성적 * 가중치 + 기본점수

  // 3. 우도(Likelihood): 데이터와 모델을 연결
  for (n in 1:N) {
    // 일반적인 실력으로 맞힐 확률(inv_logit)에
    // alpha(찍을 확률)를 섞어서 최종 확률(p_robust)을 계산합니다.
    // 식의 의미: (찍어서 맞힘 50%) + (실력으로 맞힘)
    real p_robust = alpha * 0.5 + (1 - alpha) * inv_logit(mu[n]);

    // 이 확률로 합격 여부(y)가 결정됨
    y[n] ~ bernoulli(p_robust);
  }
}
