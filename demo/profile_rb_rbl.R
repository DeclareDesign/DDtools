library(microbenchmark)

microbenchmark(
    curr = {
        j = do.call(rbind, test_resample)
        rownames(j) = NULL
    },
    wrapper = {
        wrapper = function(...) { rbind(..., make.row.names=FALSE) }
        k = do.call(wrapper, test_resample)
    },
    w2 = {
        q = c(test_resample, list(make.row.names=FALSE))
        l = do.call(rbind, q)
    },
    rbl = {
        z = as.data.frame(rbindlist(test_resample))
    },
    rbl_cheapdf = {
        x = rbindlist(test_resample)
        class(x) = "data.frame"
        attr(x, ".internal.selfref") = NULL
    },
    rbl_nodf = {
        y = rbindlist(test_resample)
    },
    times = 30
)

identical(z, x)
