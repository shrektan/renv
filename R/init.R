
#' Initialize a Project
#'
#' Discover packages used within the current project, and then initialize a
#' project-local private \R library with those packages. The currently-installed
#' versions of any packages in use (as detected within the default R libraries)
#' are then installed to the project's private library.
#'
#' The primary steps taken when initializing a new project are:
#'
#' 1. \R package dependencies are discovered within the \R files used within
#'    the project with [dependencies()];
#'
#' 2. Discovered packages are copied into the `renv` global package cache, so
#'    these packages can be re-used across future projects as necessary;
#'
#' 3. Any missing \R package dependencies discovered are then installed into
#'    the project's private library;
#'
#' 4. A lockfile capturing the state of the project's library is created
#'    with [snapshot()];
#'
#' 5. The project is activated with [activate()].
#'
#' This mimics the workflow provided by `packrat::init()`, but with more
#' reasonable default behaviors -- in particular, `renv` does not attempt
#' to download and store package sources, and `renv` will re-use packages
#' that have already been installed whenever possible.
#'
#' If `renv` sees that the associated project has already been initialized and
#' has a lockfile, then it will attempt to infer the appropriate action to take
#' based on the presence of a private library. If no library is available,
#' `renv` will restore the private library from the lockfile; if one is
#' available, `renv` will ask if you want to perform a 'standard' init,
#' restore from the lockfile, or activate the project without taking any
#' further action.
#'
#' @section Infrastructure:
#'
#' `renv` will write or amend the following files in the project:
#'
#' - `.Rprofile`: An auto-loader will be installed, so that new R sessions
#'   launched within the project are automatically loaded.
#'
#' - `renv/activate.R`: This script is run by the previously-mentioned
#'   `.Rprofile` to load the project.
#'
#' - `renv/.gitignore`: This is used to instruct Git to ignore the project's
#'   private library, as it does not need to be
#'
#' - `.Rbuildignore`: to ensure that the `renv` directory is ignored during
#'   package development; e.g. when attempting to build or install a package
#'   using `renv`.
#'
#' @param project The project directory.
#' @param settings A list of [settings] to be used with the newly-initialized
#'   project.
#' @param force Boolean; force initialization? By default, `renv` will refuse
#'   to initialize the home directory as a project, to defend against accidental
#'   misusages of `init()`.
#'
#' @export
init <- function(project = NULL, settings = NULL, force = FALSE) {

  # prepare and move into project directory
  project <- project %||% getwd()
  renv_init_validate_project(project, force)
  renv_init_settings(project, settings)
  setwd(project)

  # form path to lockfile, library
  library  <- renv_paths_library(project = project)
  lockfile <- file.path(project, "renv.lock")

  # determine appropriate action
  action <- renv_init_action(project, library, lockfile)

  # perform the action
  if (action == "init") {
    ensure_directory(library)
    hydrate(project, library)
    snapshot(project, library, confirm = FALSE)
  } else if (action == "restore") {
    ensure_directory(library)
    restore(project, confirm = FALSE)
  }

  # activate the newly-hydrated project
  activate(project)

}

renv_init_action <- function(project, library, lockfile) {

  has_library  <- file.exists(library)
  has_lockfile <- file.exists(lockfile)

  # figure out appropriate action
  action <- case(

    has_lockfile && has_library  ~ "ask",
    has_lockfile && !has_library ~ "restore",

    !has_lockfile && has_library  ~ "ask",
    !has_lockfile && !has_library ~ "init"

  )

  # ask the user for an action to take when required
  if (interactive() && action == "ask") {

    title <- "This project has already been initialized. What would you like to do?"
    choices <- c(
      restore = "Restore the project from the lockfile.",
      init    = "Re-initialize the project, discovering and installing R package dependencies as required.",
      nothing = "Activate the project without installing or snapshotting any packages."
    )
    selection <- utils::select.list(choices, title = title)
    action <- names(selection)

  }

  action

}

renv_init_validate_project <- function(project, force) {

  # allow all project directories when force = TRUE
  if (force)
    return(TRUE)

  # disallow attempts to initialize renv in the home directory
  home <- path.expand("~/")
  msg <- if (renv_file_same(project, home))
    "refusing to initialize project in home directory"
  else if (path_within(home, project))
    sprintf("refusing to initialize project in directory '%s'", project)

  if (!is.null(msg)) {
    msg <- paste(msg, "-- use renv::init(force = TRUE) to override")
    stopf(msg)
  }

}

renv_init_settings <- function(project, settings) {

  if (is.null(settings))
    return(NULL)

  ensure_directory(file.path(project, "renv"))
  defaults <- renv_settings_defaults()
  merged <- renv_settings_merge(defaults, settings)
  renv_settings_persist(project, merged)
  invisible(merged)

}
