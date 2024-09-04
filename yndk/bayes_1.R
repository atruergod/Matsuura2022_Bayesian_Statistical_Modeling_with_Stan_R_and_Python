

v1 = c(.01, .02, .03, .1, .1)
v2 = c(.05, .1, .05, .07, .2)
v3 = c(.1, .05, .03, .05, .04)

pxy = matrix(0, nrow=3, ncol=5)
pxy[1,] = v1
pxy[2,] = v2
pxy[3,] = v3

print(pxy)

# marginal
px = rep(0, 5)  # zero vector of size 5
for (i in 1:5) {
  px[i] = sum(pxy[,i])
}

py_x <- pxy

for (i in 1:5) {
  py_x[,i] = pxy[,i] / px[i]
}
print(py_x)

## sanity check
for (i in 1:5) {
  s = sum(py_x[,i])
  print(paste(i, "sum = ", s))
}


## Now compute p(X|Y=y2)
## p(Y=y2|X) p(X)

meas = 2  # Y=y_2
py2_x = py_x[2,]

py2_x_px = py2_x * px

Z = sum(py2_x_px)

px_y2 = py2_x_px / Z

for (i in 1:5) {
  print(paste("P(X_", i, "|Y=y2) = ", px_y2[i]))
}
print(sum(px_y2))

barplot(px_y2, names=1:5, col='#800000')

