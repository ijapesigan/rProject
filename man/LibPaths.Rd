% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rProject-lib-paths.R
\name{LibPaths}
\alias{LibPaths}
\title{Add \code{.library} to Library Paths}
\usage{
LibPaths(path)
}
\arguments{
\item{path}{Character string.
Project path.}
}
\value{
Returns the path of \code{.library}.
}
\description{
\itemize{
\item{creates a folder \code{.library} on the project path if it does not exist}
\item{creates a \code{.gitignore} file inside \code{.library} if it does not exist}
\item{adds \code{.library} to \code{.libPaths()}}
\item{sets \code{R_LIBS_USER} to \code{.library}}
}
}
\author{
Ivan Jacob Agaloos Pesigan
}
