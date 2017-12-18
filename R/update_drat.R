#' Updates our drat repo
#'
#' Needs \code{GH_TOKEN} and either \code{TRAVIS_COMMIT} or \code{APPVEYOR_REPO_COMMIT} env vars.
#'
#' @return NULL
#' @export
update_drat <- function() {

  requireNamespace("git2r") || {install.packages("git2r", repos="https://cloud.r-project.org/"); requireNamespace("git2r")}
  requireNamespace("drat")  || {install.packages("drat",  repos="https://cloud.r-project.org/"); requireNamespace("drat")}

  m <- tempfile()
  url <- sprintf("https://%s@github.com/DeclareDesign/declaredesign.github.io.git", Sys.getenv("GH_TOKEN"))
  repo <- git2r::clone(url, m)


  git2r::config(repo=repo, user.name="DeclareDesign Travis", user.email="team@declaredesign.org", push.default="simple")

  build <- dir(
    switch(.Platform$OS.type, "windows"='.', '..'),  # Work around - appveyor uses R CMD INSTALL --build, linux/mac use devtools::build
    pattern="[.](zip|tgz|tar[.]gz)$",
    full.names = TRUE)

  if(length(build) == 0){
    message("No built objects found for drat")
    return(1)
  }
  else if(length(build) > 1){
    message("Multiple objects found for drat !?\n", paste0("*  ", build, collapse = "\n"), "\nUsing ", build[1], " only.")
    build <- build[1]
  }

  COMMIT=Sys.getenv("TRAVIS_COMMIT", Sys.getenv("APPVEYOR_REPO_COMMIT", "(Unknown commit)"))
  PKG_REPO=basename(build)

  msg <- sprintf("Travis update %s build %s (%s %s)", PKG_REPO, COMMIT, .Platform$OS.type, R.version.string)

  options(dratRepo=m, dratBranch="master")
  drat::insertPackage(build, commit=msg)
}
