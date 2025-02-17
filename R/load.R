
# tools for loading an renv (typically done at R session init)
renv_load_r <- function(fields) {

  # check for missing fields
  if (is.null(fields)) {
    warning("missing required [R] section in lockfile")
    return(NULL)
  }

  # load repositories
  repos <- fields$repos
  if (!is.null(repos))
    options(repos = repos)

  # load (check) version
  version <- fields$Version
  if (!is.null(version)) {
    if (version_compare(version, getRversion()) != 0) {
      fmt <- "Project requested R version '%s' but '%s' is currently being used"
      warningf(fmt, version, getRversion())
    }
  }

}

renv_load_bioconductor <- function(fields) {

  # check for missing field
  if (is.null(fields))
    return(NULL)

  repos <- fields$Repositories
  if (!is.null(repos))
    options(bioconductor.repos = repos)

}

renv_load_project <- function(project) {
  Sys.setenv(RENV_PROJECT = normalizePath(project, winslash = "/"))
}

renv_load_profile <- function(project = NULL) {
  project <- project %||% renv_project()

  profile <- renv_paths_root(".Rprofile")
  if (!file.exists(profile))
    return(FALSE)

  status <- catch(source(profile))
  if (inherits(status, "error")) {
    fmt <- paste("Error sourcing '%s': %s")
    warningf(fmt, aliased_path(profile), conditionMessage(status))
    return(FALSE)
  }

  TRUE
}

renv_load_envvars <- function(project = NULL) {
  project <- project %||% renv_project()
  Sys.setenv(
    R_PROFILE_USER = "",
    R_ENVIRON_USER = file.path(project, ".Renviron")
  )
}

renv_load_libpaths <- function(project = NULL) {
  renv_libpaths_activate(project)
  libpaths <- renv_libpaths_all()
  lapply(libpaths, renv_library_diagnose, project = project)
  Sys.setenv(R_LIBS_USER = paste(libpaths, collapse = .Platform$path.sep))
}

renv_load_python <- function(project) {

  python <- renv_python()
  if (is.null(python))
    return(FALSE)

  if (utils::file_test("-f", python))
    Sys.setenv(RETICULATE_PYTHON = python)
  else if (utils::file_test("-d", python))
    Sys.setenv(RETICULATE_PYTHON_ENV = python)
  else
    return(FALSE)

  return(TRUE)

}

renv_load_finish <- function() {
  # TODO: report to user?
}

renv_home <- function() {
  .getNamespaceInfo(.getNamespace("renv"), "path")
}
