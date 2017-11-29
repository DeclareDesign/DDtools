library(microbenchmark)
library(data.table)
deep_dive_data_2 = as.data.table(deep_dive_data)

# Sample versus sample.int
microbenchmark(
    sample.int(1000000, 1000, replace=T),
    sample(seq(1000000), 1000, replace=T),
    sample(1:1000000, 1000, replace=T),
    times=1000
)


# Unlist -- use .Internal?
microbenchmark(
    unlist(indices_split[boot_ids], use.names=F),
    unlist(indices_split[boot_ids], recursive=F, use.names=F),
    .Internal(unlist(indices_split[boot_ids], FALSE, FALSE)),
    times=100
)

# Should we get single level bs ids using unlist or just direct reference?
microbenchmark(
    unlist(split_data_on_boot_id[1]),
    unlist(split_data_on_boot_id[1], use.names=F),
    split_data_on_boot_id[1][[1]],
    times=100
)


# Should we split using data.frame or data.table?
microbenchmark(
    s1 = split(1:dim(deep_dive_data)[1], deep_dive_data$countries),
    s2 = split(1:nrow(deep_dive_data), deep_dive_data_2$countries),
    times = 50
)

# Dim or nrow?
microbenchmark(
    dim_df = dim(deep_dive_data)[1],
    nrow_df = nrow(deep_dive_data),
    times=100000
)

# Should we generate index numbers using nrow or seq_len
microbenchmark(
    1:nrow(deep_dive_data),
    1:nrow(deep_dive_data_2),
    1:15622960,
    seq_len(nrow(deep_dive_data)),
    seq_len(nrow(deep_dive_data_2)),
    times=200
)

# Should we generate index numbers using nrow or seq_len
microbenchmark(
    seq_len(10000),
    seq.int(1, 10000),
    1:10000,
    times=1000000)
