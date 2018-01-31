#' Paren hack
#'
#' By adding the paren_hack class to a function, you can invoke it via print -
#' this means you don't need ()s to do so.
#'
#' @export
print.paren_hack <- function(x, ...) x()
