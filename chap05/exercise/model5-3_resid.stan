
    data {
        int N;
        vector<lower=0, upper=1>[N] Sex;
        vector<lower=0>[N] Income;
        vector<lower=0, upper=1>[N] Y;
    }
    parameters {
        vector[3] b;
        real<lower=0> sigma;
    }
    transformed parameters {
        vector[N] mu = b[1] + b[2]*Sex[1:N] + b[3]*Income[1:N];
    }
    model {
        Y[1:N] ~ normal(mu[1:N], sigma);
    }
    generated quantities {
        array[N] real yp = normal_rng(mu[1:N], sigma);

        // --- [추가된 부분] ---
        // 잔차(epsilon) = 관측값(Y) - 추정된 평균(mu)
        vector[N] epsilon;
        epsilon = Y - mu;
    }
    