.LintChecks <- function(type = NULL) {
  # the checks of a project type; talks run the "kept" rules only
  # (guide 010): the look of a talk is free
  r <- c(
    ".LintRReturn", ".LintRNamespace", ".LintRNamedArgs", ".LintRBraces",
    ".LintRNolint", ".LintRUndesirable", ".LintRFiles", ".LintRExports",
    ".LintRSkips", ".LintRmdFigChunks"
  )
  cpp <- c(
    ".LintCppHeader", ".LintCppDeclarations", ".LintCppFiles",
    ".LintCppNames", ".LintCppNamespace", ".LintCppConstRef", ".LintCppFormat"
  )
  math <- c(
    ".LintTexCite", ".LintTexBold", ".LintTexMath", ".LintTexMacros",
    ".LintTexSymbols"
  )
  layout <- c(
    ".LintTexLabels", ".LintTexTilde", ".LintTexNumbers", ".LintTexIndent",
    ".LintTexGraphics", ".LintTexFloats", ".LintGif"
  )
  markdown <- c(
    ".LintMdBullets", ".LintMdHeadings", ".LintMdFences", ".LintMdLinks"
  )
  if (identical(x = type, y = "talk")) {
    c(r, cpp, math)
  } else {
    c(r, cpp, math, layout, markdown)
  }
}
