#' Build design library template and cache diagnosis grid
#'
#' @param topic the vignette topic
#' @param file to save the Rdata to
#' @param cache_loc to save the cache data to
#'
build_library_cache <- function(
  topic,
  file=file.path("~/cache", paste0(topic, ".Rdata")),
  cache_loc=file.path("~/cache", topic))
{
  require(DeclareDesign)
  require(memoise)
  require(pryr)

  message("removing old cached files")
  system(sprintf("rm -rf %s && mkdir -p %s", cache_loc, cache_loc))



  vig <- vignette(topic)

  Rscript <- file.path(vig$Dir, "doc", vig$R)

  e <- new.env(parent = globalenv())
  sys.source(Rscript, e)

  template_fun <- get(paste0(topic, "_template"), e)



  declare_and_diagnose_memo <- memoise(
    function(...){
      dec <- template_fun(...)
      diag <- diagnose_design(dec)
      code <- deparse(pryr::substitute_q(body(template_fun), list(...)))
      code <- paste(code[grep('match.arg|as.numeric', code, invert = TRUE)], collapse='\n')
      list(dec, diag, code)
    },
    cache = cache_filesystem(cache_loc))


  v <- c(lapply(formals(template_fun), eval), stringsAsFactors=FALSE)

  combos <- do.call(expand.grid, v)



  for(i in 1:nrow(combos)) {
    message(i," of ", nrow(combos), "\n")
    d <- do.call(declare_and_diagnose_memo, combos[i,,drop=FALSE])
    # diagnose_memo()

  }

  designer <- function(...) {
    call <- match.call()
    call[[1]] <- quote(declare_and_diagnose_memo)
    d <- eval(call)
    # d <- declare_and_diagnose_memo(N=N, beta_A=beta_A, beta_B=beta_B, gamma_AB=gamma_AB)
    structure(d[[1]], diagnosis=d[[2]], code=d[[3]])
  }
  formals(designer) <- formals(template_fun)

  diagnoser <- function(design, ...) {

    attr(design, "diagnosis")

  }

  save(declare_and_diagnose_memo, designer, diagnoser, template_fun, file=file)


}
