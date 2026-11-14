.ConformHouseRows <- function(output) {
  # the rows of the printed house table: one line per row (`file line rule
  # message level`), or, when R wraps the table at its width, a block
  # `file line rule` and below it a block `message level` in the same order
  start <- which(x = output == "House checks:")
  if (length(x = start) == 0L) {
    rows <- list()
  } else {
    lines <- output[-seq_len(length.out = start[[1]])]
    one <- regmatches(
      x = lines,
      m = regexec(
        pattern = paste0(
          "^\\s*(\\S+)\\s+([0-9]+|NA)\\s+(\\S+)\\s+(.*\\S)\\s+",
          "(error|warning)\\s*$"
        ),
        text = lines
      )
    )
    one <- Filter(
      f = function(x) {
        length(x = x) == 6L
      },
      x = one
    )
    rows <- lapply(
      X = one,
      FUN = function(x) {
        .ConformHouseRow(
          file = x[[2]],
          line = x[[3]],
          rule = x[[4]],
          message = x[[5]],
          level = x[[6]]
        )
      }
    )
    head_a <- grep(pattern = "^\\s*file\\s+line\\s+rule\\s*$", x = lines)
    head_b <- grep(pattern = "^\\s*message\\s+level\\s*$", x = lines)
    both <- length(x = head_a) > 0L && length(x = head_b) > 0L
    if (length(x = one) == 0L && both) {
      # block A runs to the header of block B (a blank line may or may not
      # separate them); block B runs to the first line that is not a row
      block_a <- lines[seq_len(length.out = head_b[[1]] - 1L)]
      block_a <- block_a[-seq_len(length.out = head_a[[1]])]
      block_a <- block_a[nzchar(x = trimws(x = block_a))]
      block_b <- lines[-seq_len(length.out = head_b[[1]])]
      block_b <- block_b[
        cumsum(x = !grepl(pattern = "(error|warning)\\s*$", x = block_b)) == 0L
      ]
      left <- regmatches(
        x = block_a,
        m = regexec(
          pattern = "^\\s*(\\S+)\\s+([0-9]+|NA)\\s+(\\S+)\\s*$",
          text = block_a
        )
      )
      right <- regmatches(
        x = block_b,
        m = regexec(
          pattern = "^\\s*(.*\\S)\\s+(error|warning)\\s*$",
          text = block_b
        )
      )
      if (length(x = left) == length(x = right)) {
        rows <- Map(
          f = function(a, b) {
            .ConformHouseRow(
              file = a[[2]],
              line = a[[3]],
              rule = a[[4]],
              message = b[[2]],
              level = b[[3]]
            )
          },
          a = left,
          b = right
        )
      }
    }
  }
  unname(obj = rows)
}
