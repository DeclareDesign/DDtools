#' Updates our drat repo
#'
#' Needs \code{GH_TOKEN} and either \code{TRAVIS_COMMIT} or \code{APPVEYOR_REPO_COMMIT} env vars.
#'
#' @return NULL
#' @export
update_drat <- function() {

  # git2r needs to be binary, but drat can install from source easily since it doesn't need any compilation
  load_instally("ropensci/git2r", from="cran")
  load_instally("eddelbuettel/drat")

  m <- tempfile()
  url <- "https://github.com/DeclareDesign/declaredesign.github.io.git"
  repo <- git2r::clone(url, m)


  git2r::config(repo=repo, user.name="DeclareDesign Travis", user.email="team@declaredesign.org", push.default="simple")

  build <- dir(
    path=switch(.Platform$OS.type, "windows"='.', '..'),  # Work around - appveyor uses R CMD INSTALL --build, linux/mac use devtools::build
    pattern=switch(.Platform$OS.type, "windows"="[.]zip$", "[.](tgz|tar[.]gz)$"),
    full.names = TRUE)


  if(length(build) == 0){
    message("No built objects found for drat")
    return(1)
  }
  else if(length(build) > 1){
    message("Multiple objects found for drat !?\n", paste0("*  ", build, collapse = "\n"), "\nUsing ", build[1], " only.")
    build <- build[1]
  }

  COMMIT=substr(Sys.getenv("TRAVIS_COMMIT", Sys.getenv("APPVEYOR_REPO_COMMIT", "!Unknown")), 1, 8)
  PKG_REPO=basename(build)

  msg <- sprintf("Travis %s:%s (%s %s)", COMMIT, PKG_REPO, R.version$os, getRversion())

  options(dratRepo=m, dratBranch="master")
  drat::insertPackage(build, commit=msg)
  message("Pushing...")
  git2r::push(repo, credentials=git2r::cred_token("GH_TOKEN")) # push is commented out on drat 1.4 for git2r
}


class(update_drat) <- c("paren_hack", "function")
