library(microbenchmark)

df = data.frame(X=1:20, Y=2:21)
df = df[rep(1:nrow(df), 5000), ]
df = df[sample(1:nrow(df)), ]

microbenchmark(
  m1 = {
    un = unique(df$X)
    index_maps_1 = unname(sapply(df$X, function(i) {
      which(un == i)
    }))
  },
  m2 = {
    un = unique(df$X)
    result = numeric(length(df$X))
    for(i in un) {
      result[df$X == i] = which(un == i)
    }
  },
  m3 = {
    un = unique(df$X)
    result_2 = numeric(length(df$X))
    for(i in seq_along(un)) {
      result_2[df$X == un[i]] = i
    }
  },
  times=100
)
