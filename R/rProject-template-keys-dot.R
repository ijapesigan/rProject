.TemplateKeys <- function(settings = list(),
                          public = NA_character_) {
  # the placeholders that template files may hold, and their values:
  # project (project.R), public (.setup/repo/public-github.md, as
  # owner/repository) with its owner and repo, and the daily docker
  # workflow's title, schedule (workflow_cron), and next (workflow_next:
  # one or more images to start)
  first <- function(x) {
    ifelse(test = length(x = x) > 0L, yes = x[1], no = "")
  }
  cron <- first(settings$workflow_cron)
  # workflow_next may name several images (one dispatch each)
  following <- settings$workflow_next
  following <- following[nzchar(x = following)]
  public <- ifelse(test = is.na(x = public), yes = "", no = public)
  list(
    project = first(settings$project),
    public = public,
    owner = sub(pattern = "/.*$", replacement = "", x = public),
    repo = sub(pattern = "^.*/", replacement = "", x = public),
    title = first(settings$workflow_title),
    schedule = ifelse(
      test = nzchar(x = cron),
      yes = paste0("  schedule:\n    - cron: \"", cron, "\""),
      no = ""
    ),
    `next` = paste(
      vapply(
        X = following,
        FUN = function(x) {
          paste0(
            "\n      - name: Trigger the next image\n",
            "        run: |\n",
            "          curl -fsS -X POST \\\n",
            "            -H \"Authorization: Bearer ${{ secrets.PAT }}\" \\\n",
            "            -H \"Accept: application/vnd.github+json\" \\\n",
            "            https://api.github.com/repos/",
            x,
            "/dispatches \\\n",
            "            -d '{\"event_type\":\"base-image-built\"}'"
          )
        },
        FUN.VALUE = character(length = 1),
        USE.NAMES = FALSE
      ),
      collapse = ""
    )
  )
}
