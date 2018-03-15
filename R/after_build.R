
#' @export
after_build <- function() {

  os <- Sys.getenv("TRAVIS_OS_NAME")

  if(os == "linux") {
    load_instally("hadley/devtools")  
    load_instally("r-lib/covr")
    
    NOT_CRAN <- Sys.getenv("NOT_CRAN")
    Sys.setenv(NOT_CRAN="false")
    message("*** Running coveralls...\n\n")
    covr::coveralls(quiet=FALSE)
    Sys.setenv(NOT_CRAN=NOT_CRAN)

    message("*** Source build...\n\n")
    time <- system.time(
      file <- devtools::build()
    )
    message("*** Built ", file, " in ", time["elapsed"], "\n")
    
  } else if (os == "osx") {
    load_instally("hadley/devtools")

    message("*** Mac build...\n\n")
    time <- system.time(
      file <- devtools::build(binary = TRUE, args = c('--preclean'))
    )
    message("*** Built ", file, " in ", time["elapsed"], "\n")
  } else {
    message("*** We are probably (?) on appveyor windows")
    load_instally("devtools", from="cran")
  }
  
  if(Sys.getenv("TRAVIS_PULL_REQUEST") == "false" && Sys.getenv("TRAVIS_BRANCH") == "master") {
    message("Updating drat via travis")
    Sys.sleep(10*rexp(1, 1/10))
    DDtools::update_drat()
  } else if (Sys.getenv("APPVEYOR_PULL_REQUEST_NUMBER") == "" && Sys.getenv("APPVEYOR_REPO_BRANCH") == "master") {
    message("Updating drat via appveyor")
    Sys.sleep(10*rexp(1, 1/10))
    DDtools::update_drat()
  }

}

class(after_build) <- c("paren_hack", "function")

load_instally <- function(repo, pkg=basename(repo), from="github"){
  if(!requireNamespace(pkg)){
    switch(from,
      github=devtools::install_github(repo),
      cran=install.packages(pkg, repos="https://cloud.r-project.org/", type = .Platform$pkgType)
    )
    if(!requireNamespace(pkg)) warning(repo, " installation or loading failed !?")
  }
}
