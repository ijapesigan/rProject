.UploadDest <- function(path) {
  # Roar: /scratch/ibp5092/Work/upload; elsewhere, next to the projects
  roar <- "/scratch/ibp5092/Work/upload"
  if (dir.exists(paths = roar)) {
    roar
  } else {
    file.path(dirname(path = path), "upload")
  }
}
