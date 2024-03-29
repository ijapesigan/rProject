% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rProject-install-local.R
\name{InstallLocal}
\alias{InstallLocal}
\title{Install Applications on Local Machine}
\usage{
InstallLocal(
  what = c("tmux", "julia", "mpdemo", "lazygit", "pfetch", "quarto"),
  all = FALSE,
  force = FALSE
)
}
\arguments{
\item{what}{Character string.
Vector of applications to install.
Valid values include
\code{"tmux"}, \code{"julia"}, \code{"mpdemo"}, \code{"lazygit"}, \code{"pfetch"}, and \code{"quarto"}.}

\item{all}{Logical.
If \code{all = TRUE}, ignore \code{what} and install all valid \code{what} values.}

\item{force}{Logical.
If \code{force = TRUE}, install whether or not the application is
available in the system.}
}
\description{
Install Applications on Local Machine
}
\author{
Ivan Jacob Agaloos Pesigan
}
