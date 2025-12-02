
    data {
      int<lower=0> N1;
      int<lower=0> N2;
      vector[N1] Y1;
      vector[N2] Y2;
    }
    parameters {
      real mu1;             // 그룹 1의 평균
      real mu2;             // 그룹 2의 평균
      real<lower=0> sigma;  // 공통 표준편차 (하나만 사용)
    }
    model {
      mu1 ~ normal(0, 100);
      mu2 ~ normal(0, 100);
      sigma ~ cauchy(0, 5);

      Y1 ~ normal(mu1, sigma);
      Y2 ~ normal(mu2, sigma);
    }
    