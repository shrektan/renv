% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/status.R
\name{status}
\alias{status}
\title{Status}
\usage{
status(project = NULL)
}
\arguments{
\item{project}{The project directory. If \code{NULL}, then the active
project will be used. If no project has been specifically activated,
the current working directory is used.}
}
\description{
Report differences between the project's lockfile and the current state of
the private library (if any).
}
