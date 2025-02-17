% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/remove.R
\name{remove}
\alias{remove}
\title{Remove Packages}
\usage{
remove(packages, library = NULL)
}
\arguments{
\item{packages}{A character vector of \R packages to remove.}

\item{library}{The library from which packages should be removed. When
\code{NULL}, the active library (that is, the first entry reported in
\code{.libPaths()}) is used instead.}
}
\description{
Remove (uninstall) \R packages.
}
