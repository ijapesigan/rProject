.ConformCommand <- function(command,
                            args,
                            dir,
                            env = character(length = 0)) {
  # runs one command in `dir` (where R already runs: no apptainer) and
  # returns its status and its output (stdout and stderr together); the
  # tests stub this function
  old <- setwd(dir = dir)
  on.exit(expr = setwd(dir = old), add = TRUE)
  output <- suppressWarnings(
    expr = system2(
      command = command,
      args = args,
      stdout = TRUE,
      stderr = TRUE,
      env = env
    )
  )
  status <- attr(x = output, which = "status")
  list(
    status = ifelse(test = is.null(x = status), yes = 0L, no = status),
    output = as.character(x = output)
  )
}
