% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/open.R
\name{new_SOMATileDBContext_for_census}
\alias{new_SOMATileDBContext_for_census}
\title{Create SOMATileDBContext for Cell Census}
\usage{
new_SOMATileDBContext_for_census(census_version_description, ...)
}
\arguments{
\item{census_version_description}{The result of \code{get_census_version_description()}
for the desired Census version.}

\item{...}{Custom configuration options.}
}
\description{
Create a SOMATileDBContext suitable for using with \code{open_soma()}.
Typically \code{open_soma()} creates a context automatically, but it can be created
separately in order to set custom configuration options or to share it between
multiple open Census handles.
}
