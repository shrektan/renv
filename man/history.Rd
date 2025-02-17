% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/history.R
\name{history}
\alias{history}
\title{View Lockfile History}
\usage{
history(project = NULL)
}
\arguments{
\item{project}{The project directory. If \code{NULL}, then the active
project will be used. If no project has been specifically activated,
the current working directory is used.}
}
\description{
The \code{history()} function can be used to search for prior versions of the
\code{renv.lock} file used within a project.
}
\details{
The \code{history()} function is currently only implemented for projects using
\code{git} for version control.
}
