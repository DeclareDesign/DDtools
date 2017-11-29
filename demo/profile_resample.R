library(profvis)
library(fabricatr)

set.seed(19861108)

# Huge chunk of data, this will take 1-2 minutes
deep_dive_data = fabricate(
    countries = level(N = 100, gdp = rlnorm(N)),
    states = level(N = 50, population = rlnorm(N)),
    cities = level(N = 50, holiday = runif(N, 1, 365)),
    neighborhoods = level(N = 5, stoplights = draw_binary(x=0.5, N)),
    houses = level(N = 5, population = runif(N, 1, 5)),
    people = level(N = population, sex = ifelse(draw_binary(x=0.5, N), "M", "F"))
)

# Profile
profvis({
    resample_data = function(data, N, ID_labels=NULL, outer_level=1, use_dt = 0) {
        # Handle all the data sanity checks in outer_level so we don't have redundant error
        # checks further down the recursion.
        if(outer_level) {
            # Optional usage of data.table to speed up functionality
            if(requireNamespace("data.table", quietly=T)) {
                use_dt = 1
            } else {
                use_dt = 0
            }
            
            # User didn't provide an N or an ID label, it's clear they just want a regular bootstrap
            # of N units by row.
            if (missing(N) & is.null(ID_labels)) {
                return(bootstrap_single_level(data, dim(data)[1], ID_label=NULL))
            }
            
            # No negative or non-numeric Ns
            # Note: this should be rewritten when we implement the "ALL" option for a level.
            if (any(!is.numeric(N) | N%%1 | N<=0)) {
                stop(
                    "All specified Ns must be numeric and at least 1."
                )
            }
        
            # N doesn't match ID labels
            if (!is.null(ID_labels) & (length(N) != length(ID_labels))) {
                stop(
                    "If you provide more than one ID_labels to resample data for multilevel data, please provide a vector for N of the same length representing the number to resample at each level."
                )
            }
        
            # ID_labels looking for some columns we don't have
            if (any(!ID_labels %in% names(data))) {
                stop(
                    "One or more of the ID labels you provided are not columns in the data frame provided."
                )
            }
        
            # Excessive recursion depth
            if(length(N) > 10) {
                stop(
                    "Multi-level bootstrap with more than 10 levels is not advised."
                )
            }
        }
        
        # Single level bootstrap with explicit bootstrapping on a particular cluster variable
        # this is the inner-most recursion
        if(length(N)==1)
        {
            return(bootstrap_single_level(data,
                                          N[1],
                                          ID_label=ID_labels[1],
                                          check_sanity=0))
        }
        
        # OK, if not, we need to recurse

        # Split indices of data frame by the thing we're strapping on
        split_data_on_boot_id = split(seq_len(dim(data)[1]), data[,ID_labels[1]])
        
        # Do the current bootstrap level
        # sample.int is faster than sample(1:length(.)) or sample(seq.len(length(.))
        sampled_boot_values = sample.int(length(split_data_on_boot_id), N[1], replace=TRUE)

        # Iterate over each thing chosen at the current level
        results_all = lapply(sampled_boot_values, function(i) {
            # Get rowids from current bootstrap index, subset based on that
            # pass through the recursed Ns and labels, and remind the inner
            # layer that it doesn't need to sanity check and we already know
            # if data.table is around.
            # The list subset on the split is faster than unlisting
            resample_data(
                data[split_data_on_boot_id[i][[1]], ],
                N=N[2:length(N)],
                ID_labels=ID_labels[2:length(ID_labels)],
                outer_level=0,
                use_dt = use_dt
            )
        })
        
        # We could probably gain slight efficiency by only doing the rbind on the
        # outermost loop.
        if(!use_dt) {
            # With no data.table, we need to rbind and then remove row names.
            # Removing row names is as fast this way as other ways to do the same thing
            res = do.call(rbind, results_all)
            rownames(res) = NULL
        } else {
            # User has data.table, give them a speed benefit for it
            res = data.table::rbindlist(results_all)
            # Strip the things that differentiate data.table from data.frame
            # so we hand back something identical.
            class(res) = "data.frame"
            attr(res, ".internal.selfref") = NULL
        }
        # Return to preceding level
        return(res)
    }

    bootstrap_single_level <- function(data, ID_label = NULL, N, check_sanity=1) {
        # If someone directly calls, do some error checking
        if(check_sanity) {
            # dim slightly faster than nrow
            if(dim(data)[1] == 0) {
                stop("Data being bootstrapped has no rows.")
            }
            
            if (is.null(ID_label)) {
                # Simple bootstrap
                return(data[sample(seq_len(dim(data)[1]), N, replace = TRUE), , drop = F])
            } else if(!ID_label %in% colnames(data)) {
                stop("ID label provided is not a column in the data being bootstrapped.")
            }
        }
        
        # Split data by cluster ID, storing all row indices associated with that cluster ID
        # nrow passes through transparently to dim, so this is slightly faster
        indices_split = split(seq_len(dim(data)[1]), data[, ID_label])
        # Get cluster IDs (not the actual cluster values, the indices of the clusters)
        # sample.int is slightly faster than sample(1:length(.)) or sample(seq_len(length(.))
        boot_ids = sample.int(length(indices_split), size=N, replace=TRUE)
        # Get all row indices associated with every cluster ID combined
        boot_indices = unlist(indices_split[boot_ids], recursive=F, use.names=F)
        # Only take the indices we want (repeats will be handled properly)
        return(data[boot_indices, , drop=F])
    }
    
    set.seed(19861108)
    test_resample = resample_data(deep_dive_data,
                                  ID_labels=c("countries", "states", "cities"),
                                  N=c(10, 50, 50))
})
