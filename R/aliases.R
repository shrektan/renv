
# aliases used primarily for nicer / normalized text output
`_renv_aliases` <- list(
  cran         = "CRAN",
  github       = "GitHub",
  gitlab       = "GitLab",
  bitbucket    = "Bitbucket",
  bioconductor = "Bioconductor"
)

renv_alias <- function(text) {
  `_renv_aliases`[[text]] %||% text
}
