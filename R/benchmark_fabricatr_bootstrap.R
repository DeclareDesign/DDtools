library(microbenchmark)
library(fabricatr)
library(rsample)
library(resample)
library(ggplot2)

df = diamonds

microbenchmark(
  rsample = {
    out = rsample::bootstraps(df, times = 20)
    lapply(out$splits, function(x) { data.frame(x) })
  },
  us = {
    replicate(20,
              fabricatr::resample_data(df))
  }
)
