
data {
  int<lower=0> I; // people
  int<lower=1> J;             // difficulty
  array[I, J] int<lower=0, upper=1> y;  // 응답 행렬 (0:오답, 1:정답)
}

parameters {
  vector[I] theta;          // 학생 능력 (Estimated)
  vector[J] beta; // difficulty
}

model {

// prior
theta ~ normal(0, 1); // identifiability가 필요함. 왜? 능력 - 난도 0이면 1이던, 100이던 다 0이 되어서 '알 수 없음'이 되어버림
beta ~ normal(0, 1); // theta 혹은 beta 둘 중 하나는 꼭 필요함

for (i in 1:I) {
  for (j in 1:J) {
        y[i,j] ~ bernoulli_logit(theta[i] - beta[j]);
    }
  }
}

