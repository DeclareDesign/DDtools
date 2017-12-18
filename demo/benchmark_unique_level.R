library(profvis)
library(fabricatr)
library(microbenchmark)

# Generate a small data set
df_small = fabricate(city = level(N=20, elevation = runif(N, 0, 10000)),
               people = level(N=10,
                              income = rnorm(N, 60000, 20000),
                              dummy = sample(c(0,1), N, replace=T)))

# Generate a huge data set
df_huge = fabricate(countries = level(N=200,
                                      cvar1=rnorm(N),
                                      cvar2=rnorm(N),
                                      cvar3=rnorm(N)),
                    states = level(N=50,
                                   svar1=rnorm(N),
                                   svar2=rnorm(N),
                                   svar3=rnorm(N)),
                    people = level(N=50,
                                   pvar1=rnorm(N),
                                   pvar2=rnorm(N),
                                   pvar3=rnorm(N)))

# Takes data set and ID level, runs each strategy 100 times, returns results
test_speed_comparison = function(data, ID_label, times=100) {
  names_to_check = colnames(data)[!colnames(data) %in% ID_label]

  return(
  microbenchmark(
    level_variables_1 =
    sapply(names_to_check, function(i) {
    max(tapply(data[, i], list(data[, ID_label]),
               function(x)
                 length(unique(x)))) == 1
    }),
    level_variables_2 = names_to_check[which(unname(unlist(lapply(names_to_check, function(i) {
      all(unlist(lapply(split(data[, i], data[, ID_label]), function(x) { length(unique(x))==1 })))
    }))))],
    level_variables_3 = {
      expect_length = length(unique(data[[ID_label]]))
      names_to_check[which(unlist(lapply(names_to_check, function(i) {
        nrow(unique(data[, c(i, ID_label)])) == expect_length
      })))]
    },
    level_variables_4 = {
      expect_length = length(unique(data[[ID_label]]))
      names_to_check[which(unlist(lapply(names_to_check, function(i) {
        sum(!duplicated(data[, c(i, ID_label)])) == expect_length
      })))]
    },
  times=times)
  )
}

# Now, let's run our tests
test_small = test_speed_comparison(df_small, "city")
# Median: 1224 microseconds, 1114 microseconds, 1232 microseconds
test_huge = test_speed_comparison(df_huge, "countries", times=10)
# Median: ~808 miliseconds for original code, 753 miliseconds for new code