.ConformFolders <- function(path) {
  # the folders of Tree(): missing ones are made by make (info), folders
  # the type does not have are for the user to decide
  tree <- suppressMessages(expr = Tree(path = path))
  tree <- tree[!(tree$folder %in% c(".Rproj.user/", ".tmp-r/")), ]
  odd <- tree$status %in% c("not standard", "unknown")
  .ConformBind(
    rows = list(
      .ConformRow(
        rule = "folder-missing",
        class = "info",
        file = tree$folder[tree$status == "missing"],
        message = "standard folder is missing (make project creates it)"
      ),
      .ConformRow(
        rule = "folder-not-standard",
        class = "decide",
        file = tree$folder[odd],
        message = paste0(
          "folder is ",
          tree$status[odd],
          " for this type (make tree)"
        )
      )
    )
  )
}
