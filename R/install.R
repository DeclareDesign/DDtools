#' Install all DD packages
#'
#' @param DeclareDesign branch or tag
#' @param shiny branch or tag
#' @param randomizr branch or tag
#' @param fabricatr branch or tag
#' @param estimatr  branch or tag
#'

dd_install_github <- function(DeclareDesign="master",
                              shiny="master",
                              randomizr="master",
                              fabricatr="master",
                              estimatr="master")
{
  stopifnot(requireNamespace("devtools", quietly = TRUE))
  devtools::install_github("DeclareDesign/estimatr", ref=estimatr)
  devtools::install_github("DeclareDesign/fabricatr", ref=fabricatr)
  devtools::install_github("DeclareDesign/randomizr", ref=randomizr)
  devtools::install_github("DeclareDesign/DeclareDesign", ref=DeclareDesign)
  devtools::install_github("DeclareDesign/shiny", ref=shiny)
}

#' Make dependency plot
#'
#' @param fields which fields of the description to use
#'
#' @export

plot_deps <- function(fields=c('Depends', 'Imports', 'LinkingTo', 'Suggests')){
  pkgs <- c("DDshiny", "DeclareDesign", "estimatr", "randomizr", "fabricatr")
  deps <- list()

  for(pkg in pkgs){
    desc <- packageDescription(pkg, fields=fields)
    desc <- Filter(is.character, desc)
    parsed <- lapply(desc, devtools::parse_deps)
    parsed <- lapply(parsed, "[[", "name")
    deps[[pkg]] <- Reduce(base::union, parsed)
  }
  edges <- do.call(rbind, mapply(cbind, names(deps), deps))
  plot(igraph::graph_from_edgelist(edges))
}
