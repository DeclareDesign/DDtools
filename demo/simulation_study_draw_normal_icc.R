#' Draw normal data with fixed intra-cluster correlation.
#'
#' Data is generated according to the following algorithm, where \eqn{i} is
#' the index of a cluster and \eqn{j} is the index of a unit:
#'
#' \deqn{\sigma^2_{\alpha} = (\rho \sigma^2_{\epsilon}) / (1 - \rho) \cr
#' \alpha_{i} ~ \mathcal{N}(0, \sigma_{\alpha}) \cr
#' \epsilon_{ij} ~ \mathcal{N}(0, \sigma_{\epsilon}) \cr
#' x_{ij} = \mu_{i} + \alpha_{i} + \epsilon_{ij}
#'
#' This system of equations ensures inter-cluster correlation 0, intra-cluster
#' correlation in expectation \eqn{\rho}. Algorithm discussed at
#' \url{https://stats.stackexchange.com/questions/263451/create-synthetic-data-with-a-given-intraclass-correlation-coefficient-icc}
#'
#' @param x A number or vector of numbers, one mean per cluster.
#' @param N (Optional) A number indicating the number of observations to be
#' generated. Must be equal to length(cluster_ids) if provided.
#' @param cluster_ids A vector of factors or items that can be coerced to
#' clusters; the length will determine the length of the generated data.
#' @param sd A number or vector of numbers, indicating the standard deviation of
#' each cluster's error terms
#' @param rho A number indicating the desired RCC.
#' @return A vector of numbers corresponding to the observations from
#' the supplied cluster IDs.
#' @examples
#' cluster_ids = rep(1:5, 10)
#' draw_normal_icc(cluster_ids = cluster_ids)
#'
#' @importFrom stats rnorm
#'
#' @export
draw_normal_icc = function(x = 0,
                           N = NULL,
                           cluster_ids,
                           sd = 1,
                           rho = 0.5) {

  # Let's not worry about how cluster_ids are provided
  tryCatch({
    cluster_ids = as.numeric(as.factor(cluster_ids))
  }, error=function(e) {
    stop("Error coercing cluster IDs to factor levels.")
  })

  # Sanity check N
  if(!is.null(N) && !is.numeric(N)) {
    stop("If you provide an N, it must be numeric.")
  }
  if(!is.null(N) && N != length(cluster_ids)) {
    stop("If you provide an N, it must be equal to the length of provided ",
         "cluster ids")
  }

  # Sanity check x
  if(!length(x) %in% c(1, number_of_clusters)) {
    stop("x must be either one number or one number per cluster.")
  }
  if(!is.vector(x)) {
    stop("x must be a number or vector of numbers.")
  }
  if(any(!is.numeric(x))) {
    stop("x must be a number or vector of numbers.")
  }

  # Sanity check rho
  if(length(rho) > 1) {
    stop("rho must be a single number.")
  }
  if(!is.numeric(rho)) {
    stop("rho must be a number.")
  }
  if(rho > 1 | rho < 0) {
    stop("rho must be a number between 0 and 1.")
  }

  # Sanity check sd
  if(!length(sd) %in% c(1, number_of_clusters)) {
    stop("sd must be either a number or one number per cluster.")
  }
  if(!is.vector(sd)) {
    stop("sd must be a number or vector of numbers.")
  }
  if(any(!is.numeric(sd))) {
    stop("sd must be a number or vector of numbers.")
  }

  # Get number of clusters
  number_of_clusters = length(unique(cluster_ids))
  # Convert rho to implied variance per cluster
  recover_var_cluster = (rho * sd^2) / (1 - rho)

  # Cluster means are either the same or individually supplied
  if(length(x) == 1) {
    cluster_mean = rep(x, number_of_clusters)
  } else {
    cluster_mean = x
  }
  # Expand to individual means
  individual_mean = cluster_mean[cluster_ids]

  # Cluster level draws, expanded to individual level draws
  alpha_cluster = rnorm(n=number_of_clusters,
                        mean=0,
                        sd=sqrt(recover_var_cluster))[cluster_ids]

  # And error terms, which are truly individual
  epsilon_ij = rnorm(length(unique(cluster_ids)), 0, sd)

  individual_mean + alpha_cluster + epsilon_ij
}

cluster_ids = rep(1:10, each=10)
suppressWarnings({samp_dist = replicate(1000, {
  results = draw_normal_icc(cluster_ids = cluster_ids)
  ICCbare(cluster_ids, results)
})})
plot(density(samp_dist))
abline(v=0.7, col="red")
abline(v=mean(samp_dist))

suppressWarnings({samp_dist = replicate(1000, {
  results = draw_normal_icc(cluster_ids = cluster_ids,
                            sd = (0.5*(1:10)))
  ICCbare(cluster_ids, results)
})})
plot(density(samp_dist))
abline(v=0.7, col="red")
abline(v=mean(samp_dist))
abline(v=median(samp_dist), col="blue")
