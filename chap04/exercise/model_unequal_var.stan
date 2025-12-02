
    data {
      int<lower=0> N1;
      int<lower=0> N2;
      vector[N1] Y1;
      vector[N2] Y2;
    }
    parameters {
      real mu1;             // 그룹 1의 평균
      real mu2;             // 그룹 2의 평균
      real<lower=0> sigma1; // 그룹 1만의 표준편차
      real<lower=0> sigma2; // 그룹 2만의 표준편차
    }
    model {
      mu1 ~ normal(0, 100);
      mu2 ~ normal(0, 100);
      sigma1 ~ cauchy(0, 5);
      sigma2 ~ cauchy(0, 5);

      Y1 ~ normal(mu1, sigma1);
      Y2 ~ normal(mu2, sigma2);
    }
    