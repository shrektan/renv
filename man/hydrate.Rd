% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hydrate.R
\name{hydrate}
\alias{hydrate}
\title{Hydrate a Project}
\usage{
hydrate(project = NULL, library = NULL)
}
\arguments{
\item{project}{The project directory. If \code{NULL}, then the active
project will be used. If no project has been specifically activated,
the current working directory is used.}

\item{library}{The \R library to be hydrated. When \code{NULL}, the active
library as reported by \code{.libPaths()} is used.}
}
\description{
Discover the \R packages used within a project, and then install those
packages into the active library.
}
\details{
While this function is normally called as part of \code{\link[=init]{init()}}, it may be useful
to call this function explicitly when working with a new project, as it
can take care of finding and installing \R packages available on CRAN that
have not yet been installed on your machine.
}
