#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
path <- as.character(args[1])
unlink(
  c(
    file.path(
      path,
      ".setup",
      "latex",
      "bib",
      "bib.bib"
    ),
    file.path(
      path,
      ".setup",
      "latex",
      "bib",
      "quarto.bib"
    )
  )
)
warnings()
