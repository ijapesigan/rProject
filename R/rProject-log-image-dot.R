.LogImage <- function(labels = "/.singularity.d/labels.json") {
  # the user chooses the image; record the one that actually ran
  running <- Sys.getenv(
    x = "APPTAINER_NAME",
    unset = Sys.getenv(x = "SINGULARITY_NAME")
  )
  if (nzchar(running)) {
    info <- .SifLabels(file = labels)
    paste0(
      "- Image: `",
      running,
      "` (built ",
      info[["built"]],
      "; base ",
      info[["base"]],
      ")"
    )
  } else {
    "- Image: not run inside a container"
  }
}
