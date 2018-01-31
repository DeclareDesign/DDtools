
#' @export
after_build <- function() {
  load_instally("hadley/devtools")

  os <- Sys.getenv("TRAVIS_OS_NAME")

  if(os == "linux") {
    load_instally("r-lib/covr")
    NOT_CRAN <- Sys.getenv("NOT_CRAN")
    Sys.setenv(NOT_CRAN="false")
    covr::coveralls()
    Sys.setenv(NOT_CRAN=NOT_CRAN)

    devtools::build()
  } else if (os == "mac") {
    devtools::build(binary = TRUE, args = c('--preclean'))
  }

  if(Sys.getenv("TRAVIS_PULL_REQUEST") == "false" && sys.getenv("TRAVIS_BRANCH") == "master") {
    message("Updating drat via travis")
    DDtools::update_drat()
  } else if (Sys.getenv("APPVEYOR_PULL_REQUEST_NUMBER") == "" && Sys.getenv("APPVEYOR_REPO_BRANCH") == master) {
    message("Updating drat via appveyor")
    DDtools::update_drat()
  }

}

class(after_build) <- c("paren_hack", "function")

load_instally <- function(repo, pkg=basename(repo), from="github"){
  if(!requireNamespace(pkg)){
    switch(from,
      github=remotes::install_github(repo),
      cran=install.packages(pkg, repos="https://cloud.r-project.org/", type = .Platform$pkgType)
    )
    if(!requireNamespace(pkg)) warning(repo, " installation or loading failed !?")
  }
}
