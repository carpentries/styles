install_required_packages <- function(lib = NULL, repos = getOption("repos", default = c(CRAN = "https://cran.rstudio.com/"))) {

  if (is.null(lib)) {
    lib <- .libPaths()[[1]]
  }

  message("lib paths: ", paste(lib, collapse = ", "))
  required_pkgs <- c("rprojroot", "desc", "remotes", "renv", "BiocManager")
  installed_pkgs <- rownames(installed.packages(lib.loc = lib))
  missing_pkgs <- setdiff(required_pkgs, installed_pkgs)

  # The default installation of R will have "@CRAN@" as the default repository,
  # which directs contrib.url() to either force the user to choose a mirror if
  # interactive or fail if not. Since we are not interactve, we need to force
  # the mirror here.
  if ("@CRAN@" %in% repos) {
    repos <- c(CRAN = "https://cran.rstudio.com/")
  }

  if (length(missing_pkgs) != 0) {
    install.packages(missing_pkgs, lib = lib, repos = repos)
  }
}

find_root <- function() {

  cfg  <- rprojroot::has_file_pattern("^_config.y*ml$")
  root <- rprojroot::find_root(cfg)

  root
}

# set the BiocManager repositories and return a function that resets the default
# repositories.
#
# @example
# bioc_repos_example <- function() {
#   message("User repos")
#   as.data.frame(getOption("repos"))
#   reset_repos <- use_bioc_repos()
#   on.exit(reset_repos())
#   message("Bioc repos")
#   as.data.frame(getOption("repos"))
# }
# bioc_repos_example()
# as.data.frame(getOption("repos")
use_bioc_repos <- function() {
  repos <- getOption("repos")
  suppressMessages(options(repos = BiocManager::repositories()))
  function() {
    options(repos = repos)
  }
}

identify_dependencies <- function() {

  root <- find_root()

  reset_repos <- use_bioc_repos()
  on.exit(reset_repos(), add = TRUE)

  required_pkgs <- unique(c(
    ## Packages for episodes
    renv::dependencies(file.path(root, "_episodes_rmd"), progress = FALSE, error = "ignore")$Package,
    ## Packages for tools
    renv::dependencies(file.path(root, "bin"), progress = FALSE, error = "ignore")$Package
  ))

  required_pkgs
}

create_description <- function(required_pkgs) {
  d <- desc::description$new("!new")
  lapply(required_pkgs, function(x) d$set_dep(x))
  d$write("DESCRIPTION")
}

install_dependencies <- function(required_pkgs, ...) {

  reset_repos <- use_bioc_repos()
  on.exit(reset_repos(), add = TRUE)

  create_description(required_pkgs)
  on.exit(file.remove("DESCRIPTION"))
  remotes::install_deps(dependencies = TRUE, ...)

  if (require("knitr") && packageVersion("knitr") < '1.9.19') {
    stop("knitr must be version 1.9.20 or higher")
  }

}
